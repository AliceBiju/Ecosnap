import 'package:ecosnap/domain/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(User user) async {
    try{

      final docRef = user.id.isEmpty
        ? _db.collection('users').doc()
        : _db.collection('users').doc(user.id);

      final data = user.toFirestore();
      if(user.id.isEmpty){
        data['id'] = docRef.id;
      }

      await docRef.set(data);
      
    }catch(e){
      throw Exception("Erro ao salvar usuario: $e");
    }
  }

  Future<User?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) return User.fromFirestore(doc);
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final query = await _db
    .collection('users')
    .where('email',isEqualTo: email)
    .limit(1)
    .get();

    if (query.docs.isNotEmpty){
      return User.fromFirestore(query.docs.first);
    }
    return null;
  }

  Future<void> updateUser(String uid, Map<String,dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  Future <void> deleteUser(String uid) async{
  await _db.collection('users').doc(uid).delete();
  }
}

