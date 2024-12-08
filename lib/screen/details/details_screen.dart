import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_fall_2024_0/data/model/todo.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth for user identity
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:app_settings/app_settings.dart'; // For opening app settings
import 'package:intl/intl.dart'; // Import the intl package for date formatting

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

class DetailsScreen extends StatefulWidget {
  final Todo todo;

  const DetailsScreen({super.key, required this.todo});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  late TextEditingController _textController;
  late TextEditingController _descriptionController;
  late DateTime? _dueDate;
  late bool _priority;
  late Color? _selectedColor;

  final List<Color?> _colorOptions = [
    null, // Option for no color
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.yellow.shade100,
    Colors.purple.shade100,
    Colors.orange.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.todo.text);
    _descriptionController =
        TextEditingController(text: widget.todo.description);
    _dueDate = widget.todo.dueDate;
    _priority = widget.todo.priority;
    _selectedColor = widget.todo.backgroundColor;
  }

  @override
  void dispose() {
    _textController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Todo'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteTodo,
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text('Due Date: '),
                TextButton(
                  onPressed: _pickDate,
                  child: Text(
                    _dueDate == null
                        ? 'Select Date'
                        : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year} ${DateFormat('HH:mm').format(_dueDate!)}',
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Priority: '),
                Switch(
                  value: _priority,
                  onChanged: (value) {
                    setState(() {
                      _priority = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Background Color',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color ?? Theme.of(context).cardColor,
                      border: Border.all(
                        color: color == _selectedColor
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey,
                        width: color == _selectedColor ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: color == null
                        ? Icon(Icons.block, color: Colors.grey)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate ?? DateTime.now()),
      );
      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
        final formattedTime = DateFormat('HH:mm').format(_dueDate!);
      }
    }
  }

  Future<void> _saveTodo() async {
    try {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(widget.todo.id)
          .update({
        'text': _textController.text,
        'description': _descriptionController.text,
        'dueDate': _dueDate == null ? null : Timestamp.fromDate(_dueDate!),
        'priority': _priority,
        'backgroundColor': _selectedColor?.value,
      });

      if (_dueDate != null) {
        await _scheduleNotification(_dueDate!);
      }

      if (mounted) {
        Navigator.pop(context); // Navigate back to main screen after saving
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error updating todo')));
    }
  }

  Future<void> _deleteTodo() async {
    try {
      await FirebaseFirestore.instance
          .collection('todos')
          .doc(widget.todo.id)
          .delete();
      if (mounted) {
        Navigator.pop(context); // Navigate back to main screen after deleting
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting todo')));
    }
  }

  Future<void> _scheduleNotification(DateTime dueDate) async {
    final tzDateTime = tz.TZDateTime.from(dueDate, tz.local);
    await flutterLocalNotificationsPlugin.zonedSchedule(
      widget.todo.id.hashCode,
      'Task due',
      widget.todo.text,
      tzDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'general_channel',
          'General Notifications',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
