import 'package:ecosnap/domain/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    await _db.collection('users').doc(user.id).set(user.toFirestore());
  }

  Future<User> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return User.fromFirestore(doc);
  }
}
