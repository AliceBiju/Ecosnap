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

  static const String _imgBbApiKey = String.fromEnvironment(
    'IMGBB_KEY', 
    defaultValue: 'SUA_API_KEY_DO_IMGBB',
  );

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

  
  Future<(String, String)> _getCurrentUser() async {
    final userId = await SessionManager.get() ?? 'anonymous';
    if (userId == 'anonymous') return ('anonymous', 'Usuário');
    final user = await _userRepository.getUser(userId);
    return (userId, user?.name ?? user?.email ?? 'Usuário');
  }

  Future<void> createPost({
    required String title,
    required String description,
    Uint8List? imageBytes,
  }) async {
    final (userId, userName) = await _getCurrentUser();

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

    if (imageBytes != null) {
      final imageUrl = await _uploadImage(imageBytes);
      if (imageUrl != null) {
        await _repository.updateImageUrl(postId, imageUrl);
      }
    }
  }

  Stream<List<Post>> getAllPosts() {
    return _repository.getAllPosts();
  }

  Future<void> toggleLike(String postId) async {
    final userId = await SessionManager.get();
    if (userId == null) return;
    await _repository.toggleLike(postId, userId);
  }

  Future<Stream<List<Post>>?> getMyPosts({int? limit}) async {
    final userId = await SessionManager.get();
    if (userId == null) return null;
    return _repository.getPostsByUserId(userId, limit: limit);
  }

  Stream<Post?> getPostStream(String postId) {
    return _repository.getPostStream(postId);
  }

  Future<void> deletePost(String postId) async {
    await _repository.deletePost(postId);
  }
}
