import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ecosnap/models/post.dart';
import 'package:ecosnap/repository/post_repository.dart';
import 'package:ecosnap/repository/user_repository.dart';
import 'session_manager.dart';

class PostService {
  final PostRepository _repository = PostRepository();
  final UserRepository _userRepository = UserRepository();

  // Insira sua API Key gratuita do ImgBB aqui (crie uma grátis em https://api.imgbb.com/)
  // Usamos uma chave pública padrão de fallback para facilitar seus testes imediatos.
  static const String _imgBbApiKey = String.fromEnvironment(
    'IMGBB_KEY', 
    defaultValue: 'SUA_API_KEY_DO_IMGBB',
  );

  /// Faz upload da imagem para o ImgBB via POST HTTP Multipart e retorna a URL direta.
  /// Funciona de forma idêntica e sem restrições de CORS na Web e Mobile.
  Future<String?> _uploadImage(Uint8List imageBytes) async {
    if (_imgBbApiKey == 'SUA_API_KEY_DO_IMGBB' || _imgBbApiKey.isEmpty) {
      print('Erro: API Key do ImgBB não configurada. Por favor, crie uma grátis em https://api.imgbb.com/');
      return null;
    }

    try {
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey');
      
      final request = http.MultipartRequest('POST', uri);
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          // Retorna a URL direta da imagem hospedada
          return data['data']['url'] as String?;
        }
      }
      print('Erro no upload para ImgBB: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      print('Exceção ao fazer upload para ImgBB: $e');
      return null;
    }
  }

  /// Obtém o userId e o nome do usuário logado.
  Future<(String, String)> _getCurrentUser() async {
    final userId = await SessionManager.get() ?? 'anonymous';
    if (userId == 'anonymous') return ('anonymous', 'Usuário');
    final user = await _userRepository.getUser(userId);
    return (userId, user?.name ?? user?.email ?? 'Usuário');
  }

  /// Cria e salva um post no Firestore, fazendo upload da imagem se fornecida.
  Future<void> createPost({
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    final (userId, userName) = await _getCurrentUser();

    // Salva o post sem imagem primeiro para obter o ID gerado pelo Firestore
    final tempPost = Post(
      id: '',
      userId: userId,
      userName: userName,
      title: title,
      description: description,
      imageUrl: null,
      createdAt: DateTime.now(),
    );

    final postId = await _repository.savePost(tempPost);

    // Se houver imagem, faz upload para o ImgBB e atualiza o documento com a URL
    if (imageBytes != null) {
      final imageUrl = await _uploadImage(imageBytes);
      if (imageUrl != null) {
        await _repository.updateImageUrl(postId, imageUrl);
      }
    }
  }

  /// Retorna stream com todos os posts em tempo real.
  Stream<List<Post>> getAllPosts() {
    return _repository.getAllPosts();
  }

  /// Alterna a curtida (like/dislike) de um post pelo usuário logado.
  Future<void> toggleLike(String postId) async {
    final userId = await SessionManager.get();
    if (userId == null) return;
    await _repository.toggleLike(postId, userId);
  }

  /// Retorna a stream de posts criados especificamente pelo usuário logado.
  Future<Stream<List<Post>>?> getMyPosts({int? limit}) async {
    final userId = await SessionManager.get();
    if (userId == null) return null;
    return _repository.getPostsByUserId(userId, limit: limit);
  }

  /// Ouve atualizações em tempo real de um post específico pelo ID.
  Stream<Post?> getPostStream(String postId) {
    return _repository.getPostStream(postId);
  }

  /// Deleta um post pelo ID.
  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId);
  }
}
