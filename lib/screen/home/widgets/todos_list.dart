import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/screen/details/details_screen.dart';

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
    if (todos.isEmpty) return Center(child: Text('Add your first ToDo'));

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
          title: Text(
            todo.text,
            style: TextStyle(
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(builder: (context) => DetailsScreen(todo: todo)),
              );
            },
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
