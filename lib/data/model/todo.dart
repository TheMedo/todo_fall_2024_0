import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // To use IconData

class Todo {
  final String id;
  final DateTime? completedAt;
  final String text;
  final String? description;
  final DateTime? timestamp;
  final DateTime? dueDate;
  final String userId;
  final bool? priority;
  final int? icon; // New field for icon

  Todo({
    required this.id,
    required this.completedAt,
    required this.text,
    required this.timestamp,
    required this.dueDate,
    required this.userId,
    required this.description,
    required this.priority,
    required this.icon, // Add icon to the constructor
  });

  factory Todo.fromMap(String id, Map<String, dynamic> map) {
    return Todo(
      id: id,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      text: map['text']?.toString() ?? '',
      priority: map['priority'] as bool? ?? false,
      description: map['description']?.toString() ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
      dueDate: (map['dueDate'] as Timestamp?)?.toDate(),
      userId: map['userId']?.toString() ?? '',
      icon: map['icon'] as int?,
      // Deserialize the icon
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'text': text,
      'description': description,
      'priority': priority,
      'timestamp': timestamp == null ? null : Timestamp.fromDate(timestamp!),
      'dueDate': dueDate == null ? null : Timestamp.fromDate(dueDate!),
      'userId': userId,
      'icon': icon, // Serialize the icon as codePoint
    };
  }
}
