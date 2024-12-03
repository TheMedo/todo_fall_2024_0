import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/data/util/format.dart';
import 'package:todo_fall_2024_0/screen/details/details_screen.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart';

import '../../../data/model/todo.dart';

class TodosList extends StatelessWidget {
  const TodosList({
    super.key,
    required this.todos,
    required this.onCheck,
  });

  final List<Todo> todos;
  final void Function(String todoId, bool checked) onCheck;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.completedAt != null;

        return ListTile(
          leading: IgnorePointer(
            child: Checkbox(
              value: isCompleted,
              onChanged: (value) {},
            ),
          ),
          title: Row(
            children: [
              if (todo.icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child:
                      Icon(IconData(todo.icon!, fontFamily: 'MaterialIcons')),
                ),
              Text(
                todo.text,
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
          subtitle: todo.dueDate == null
              ? null
              : Text(
                  formatDateTime(todo.dueDate),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DateTime.now().isAfter(todo.dueDate!)
                          ? Colors.redAccent
                          : null),
                ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: Icon(
                      todo.priority ?? false ? Icons.star : Icons.star_border),
                  color: todo.priority ?? false ? Colors.yellow : Colors.grey,
                  onPressed: () {
                    final isChecked = todo.priority ?? false;
                    _updatePriority(todo.id, !isChecked); // Firestore update
                  }),
              IconButton(
                icon: Icon(Icons.chevron_right),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                        builder: (context) => DetailsScreen(todo: todo)),
                  );
                },
              ),
            ],
          ),
          onTap: () {
            final value = !isCompleted;
            final todoId = todo.id;
            onCheck(todoId, value);
          },
        );
      },
    );
  }
}

Future<void> _updatePriority(String todoId, bool priority) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .update({
      'priority': priority, // Update the priority status
    });
  } catch (e, st) {
    log('Error updating priority', error: e, stackTrace: st);
  }
}
