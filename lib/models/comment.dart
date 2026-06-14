import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String userId;
  final String userName;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Comment(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Usuário',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
