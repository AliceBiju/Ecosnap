import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String profilePictureURL;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureURL,
    required this.createdAt,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      profilePictureURL: data['profilePictureURL'] ?? '',
      createdAt: data['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profilePictureURL': profilePictureURL,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
