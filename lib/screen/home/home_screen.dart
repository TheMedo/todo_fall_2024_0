import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_fall_2024_0/screen/home/sheets/filter_bottom_sheet.dart';
import 'package:todo_fall_2024_0/screen/home/widgets/search_filter_bar.dart';
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
  List<Todo> allTodos = [];
  List<Todo> displayTodos = [];
  String searchQuery = '';
  bool hideCompleted = false;
  String selectedSortOption = 'timestamp';
  DateTime? timestamp; // Ensure correct type

  StreamSubscription<List<Todo>>? _subscription;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    _subscription = _getTodosByUserId(userId).listen((todos) {
      setState(() {
        allTodos = todos;
        displayTodos = _filterTodos(todos);
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchFilterBar(
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                  displayTodos = _filterTodos(allTodos);
                });
              },
              onFilter: () {
                showModalBottomSheet<bool>(
                  context: context,
                  builder: (context) {
                    return FilterBottomSheet(
                      initialHideCompleted: hideCompleted,
                      initialSortOption: selectedSortOption,
                      onHideCompleted: (checked) {
                        setState(() {
                          hideCompleted = checked;
                          displayTodos = _filterTodos(allTodos);
                        });
                      },
                      onSortOptionChanged: (sortOption) {
                        setState(() {
                          selectedSortOption = sortOption;
                          displayTodos = _filterTodos(allTodos);
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: TodosList(
              todos: displayTodos,
              onCheck: (todoId, checked) {
                _updateTodoStatus(todoId, checked);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextInputRow(
              onAdd: (text) {
                if (userId == null) return;
                _addTodo(text, userId);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Todo> _filterTodos(List<Todo> todos) {
    final filteredTodos = todos.where((todo) {
      return todo.text.contains(searchQuery);
    }).where((todo) {
      return hideCompleted ? todo.completedAt == null : true;
    }).toList();

    return filteredTodos
      ..sort((a, b) {
        if (selectedSortOption == 'priority') {
          return b.priority ? 1 : -1;
        } else if (selectedSortOption == 'timestamp') {
          final aTimestamp = a.timestamp ?? DateTime.now();
          final bTimestamp = b.timestamp ?? DateTime.now();
          return bTimestamp.compareTo(aTimestamp);
        }
        return 0;
      });
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
