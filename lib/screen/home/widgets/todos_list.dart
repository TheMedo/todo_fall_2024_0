import 'package:flutter/material.dart';

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
          leading: Checkbox(
            value: isCompleted,
            onChanged: (value) {
              if (value != null) {
                final todoId = todo.id;
                onCheck(todoId, value);
              }
            },
          ),
          title: Text(
            todo.text,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        );
      },
    );
  }
}
