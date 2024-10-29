import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/data/model/todo.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({
    required this.todo,
    super.key,
  });

  final Todo todo;

  @override
  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  TextEditingController? _controller;

  String? text;

  @override
  void initState() {
    super.initState();
    text = widget.todo.text;
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDarkMode = brightness == Brightness.dark;

    return PopScope(
      onPopInvokedWithResult: (isPopped, _) {
        if (isPopped && text != widget.todo.text) {
          _updateTodo(widget.todo.id, text ?? '');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Details',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  text = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                _deleteTodo(widget.todo.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode ? Colors.red : Colors.deepOrange,
                foregroundColor: Colors.white,
              ),
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _deleteTodo(String todoId) async {
  try {
    await FirebaseFirestore.instance.collection(collectionTodo).doc(todoId).delete();
  } catch (e, st) {
    log('Error deleting todo', error: e, stackTrace: st);
  }
}

Future<void> _updateTodo(String todoId, String text) async {
  try {
    await FirebaseFirestore.instance.collection(collectionTodo).doc(todoId).update({
      'text': text,
    });
  } catch (e, st) {
    log('Error deleting todo', error: e, stackTrace: st);
  }
}
