import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_fall_2024_0/screen/home/widgets/text_input_row.dart';
import 'package:todo_fall_2024_0/screen/home/widgets/todos_list.dart';

import '../../data/model/todo.dart';

const collectionTodo = 'todos';
const keyUserId = 'userId';
const keyText = 'text';
const keyCompletedAt = 'completedAt';
const keyTimestamp = 'timestamp';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ToDo',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await GoogleSignIn().signOut();
            },
            icon: Icon(Icons.logout),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: _getTodosByUserId(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return Center(child: Text('Add your first ToDo'));
                }

                return TodosList(
                  todos: snapshot.data ?? [],
                  onCheck: (todoId, checked) =>
                      _updateTodoStatus(todoId, checked),
                );
              },
            ),
          ),
          TextInputRow(
            onAdd: (text) {
              if (userId == null) return;
              _addTodo(text, userId);
            },
          ),
        ],
      ),
    );
  }
}

Future<void> _addTodo(String text, String userId) async {
  try {
    await FirebaseFirestore.instance.collection(collectionTodo).add({
      keyText: text,
      keyUserId: userId,
      keyTimestamp: FieldValue.serverTimestamp(),
      keyCompletedAt: null,
    });
  } catch (e, st) {
    log('Error adding todo', error: e, stackTrace: st);
  }
}

Stream<List<Todo>> _getTodosByUserId(String? userId) {
  return FirebaseFirestore.instance
      .collection(collectionTodo)
      .where(keyUserId, isEqualTo: userId)
      .orderBy(keyTimestamp, descending: true)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) {
      return Todo.fromMap(doc.id, doc.data());
    }).toList();
  });
}

Future<void> _updateTodoStatus(String todoId, bool checked) async {
  await FirebaseFirestore.instance
      .collection(collectionTodo)
      .doc(todoId)
      .update({
    keyCompletedAt: checked ? FieldValue.serverTimestamp() : null,
  });
}
