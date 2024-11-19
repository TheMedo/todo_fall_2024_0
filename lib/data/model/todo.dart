import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String id;
  final DateTime? completedAt;
  final String text;
  final String? description;
  final DateTime? timestamp;
  final DateTime? dueDate;
  final String userId;

  Todo({
    required this.id,
    required this.completedAt,
    required this.text,
    required this.description,
    required this.timestamp,
    required this.dueDate,
    required this.userId,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      text: map['text']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      userId: map['userId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'text': text,
      'description': description,
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'userId': userId,
    };
  }
}
