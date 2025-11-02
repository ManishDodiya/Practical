import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class PostModel extends Equatable {
  final String id;
  final String message;
  final String username;
  final String userId;
  final DateTime timestamp;

  const PostModel({
    required this.id,
    required this.message,
    required this.username,
    required this.userId,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'username': username,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory PostModel.fromMap(Map<String, dynamic> map, String documentId) {
    return PostModel(
      id: documentId,
      message: map['message'] ?? '',
      username: map['username'] ?? '',
      userId: map['userId'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }

  @override
  List<Object?> get props => [id, message, username, userId, timestamp];
}

