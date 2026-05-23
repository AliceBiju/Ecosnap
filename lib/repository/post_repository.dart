import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecosnap/models/post.dart';

class PostRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'posts';

  /// Salva um novo post no Firestore e retorna o ID gerado.
  Future<String> savePost(Post post) async {
    final ref = await _db.collection(_collection).add(post.toFirestore());
    return ref.id;
  }

  /// Busca um post pelo ID.
  Future<Post?> getPost(String id) async {
    final doc = await _db.collection(_collection).doc(id).get();
    if (!doc.exists) return null;
    return Post.fromFirestore(doc);
  }

  /// Retorna todos os posts ordenados do mais recente para o mais antigo.
  Stream<List<Post>> getAllPosts() {
    return _db
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Busca posts de um usuário específico com um limite opcional para scroll infinito.
  Stream<List<Post>> getPostsByUserId(String userId, {int? limit}) {
    Query query = _db
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snap) =>
        snap.docs.map((doc) => Post.fromFirestore(doc)).toList());
  }

  /// Alterna a curtida (toggle) de um post por parte de um usuário.
  Future<void> toggleLike(String postId, String userId) async {
    final docRef = _db.collection(_collection).doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final List<dynamic> likedBy = data['likedBy'] ?? [];

    if (likedBy.contains(userId)) {
      // Já curtiu -> Remove curtida (descurtir)
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([userId])
      });
    } else {
      // Não curtiu -> Adiciona curtida
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([userId])
      });
    }
  }

  /// Ouve atualizações em tempo real de um post específico pelo ID.
  Stream<Post?> getPostStream(String id) {
    return _db.collection(_collection).doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Post.fromFirestore(doc);
    });
  }

  /// Atualiza a URL da imagem de um post existente.
  Future<void> updateImageUrl(String postId, String imageUrl) async {
    await _db.collection(_collection).doc(postId).update({'imageUrl': imageUrl});
  }

  /// Deleta um post pelo ID.
  Future<void> deletePost(String postId) async {
    await _db.collection(_collection).doc(postId).delete();
  }
}
