import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String profilePictureURL;

  User({
    this.id = '',
    required this.name,
    required this.email,
    required this.password,
    this.profilePictureURL = '',
  });

  User.forRegistration({
    required this.name,
    required this.email,
    required this.password
  }) : id = '',
       profilePictureURL='';

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      password: data['password'] ?? '',
      profilePictureURL: data['profilePictureURL'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'profilePictureURL': profilePictureURL,
    };
  }

}
