import 'package:ecosnap/domain/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> savePost(Post post) async {
    await _db.collection('posts').doc(post.id).set(post.toFirestore());
  }

  Future<Post> getPost(String uid) async {
    final doc = await _db.collection('posts').doc(uid).get();
    return Post.fromFirestore(doc);
  }
}
