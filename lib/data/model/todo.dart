import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: Use https://pub.dev/packages/equatable
class Todo {
  final String id;
  final DateTime? completedAt;
  final String text;
  final DateTime? timestamp;
  final String userId;

  Todo({
    required this.id,
    required this.completedAt,
    required this.text,
    required this.timestamp,
    required this.userId,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      text: map['text']?.toString() ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      userId: map['userId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'text': text,
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
      'userId': userId,
    };
  }

  bool isEqualTo(Todo other) {
    if (text != other.text) return false;
    if (completedAt == null && other.completedAt != null) return false;
    if (completedAt != null && other.completedAt == null) return false;
    return true;
  }
}
