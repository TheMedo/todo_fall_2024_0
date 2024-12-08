import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Todo {
  final String id;
  final DateTime? completedAt;
  final String text;
  final DateTime? timestamp;
  final DateTime? dueDate;
  final String userId;
  final String? description;
  final bool priority;
  final Color? backgroundColor;

  Todo({
    required this.id,
    required this.completedAt,
    required this.text,
    required this.timestamp,
    required this.dueDate,
    required this.userId,
    required this.description,
    required this.priority,
    this.backgroundColor,
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      text: map['text']?.toString() ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      userId: map['userId']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      priority: map['priority'] as bool? ?? false,
      backgroundColor: map['backgroundColor'] != null
          ? Color(map['backgroundColor'] as int)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt': completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'text': text,
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'userId': userId,
      'description': description,
      'priority': priority,
      'backgroundColor': backgroundColor?.value,
    };
  }
}