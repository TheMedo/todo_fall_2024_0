import 'package:flutter/material.dart';
import 'package:todo_fall_2024_0/data/util/format.dart';
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
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.completedAt != null;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: todo.backgroundColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
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
            subtitle: todo.dueDate == null
                ? null
                : Text(
              formatDateTime(todo.dueDate),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: DateTime.now().isAfter(todo.dueDate!)
                    ? Colors.redAccent
                    : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => DetailsScreen(todo: todo),
                  ),
                );
              },
            ),
            onTap: () {
              final value = !isCompleted;
              final todoId = todo.id;
              onCheck(todoId, value);
            },
          ),
        );
      },
    );
  }
}