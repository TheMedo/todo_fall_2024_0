import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_fall_2024_0/data/model/todo.dart';
import 'package:todo_fall_2024_0/data/util/format.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart';
import 'package:todo_fall_2024_0/screen/home/widgets/icon_picker.dart'; // Import the icon picker

final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
  TextEditingController? _descriptionController;

  String? text;
  String? description;
  DateTime? dueDate;
  IconData? selectedIcon;

  @override
  void initState() {
    super.initState();
    text = widget.todo.text;
    description = widget.todo.description;
    dueDate = widget.todo.dueDate;
    final icon = widget.todo.icon;
    selectedIcon =
        icon == null ? null : IconData(icon, fontFamily: 'MaterialIcons');
    _controller = TextEditingController(text: text);
    _descriptionController = TextEditingController(text: description);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _descriptionController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (isPopped, _) {
        if (isPopped && text != widget.todo.text) {
          _updateText(widget.todo.id, text ?? '');
        }
        if (isPopped && description != widget.todo.description) {
          _updateDescription(widget.todo.id, description ?? '');
        }
        if (isPopped && selectedIcon?.codePoint != widget.todo.icon) {
          _updateIcon(widget.todo.id, selectedIcon);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Details',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                _deleteTodo(widget.todo.id);
                Navigator.of(context).pop();
              },
              icon: Icon(Icons.delete_outline),
              tooltip: 'Delete',
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Icon selection
              Row(
                children: [
                  selectedIcon != null
                      ? Icon(selectedIcon, size: 40)
                      : Icon(Icons.category, size: 40),
                  SizedBox(width: 8),
                  TextButton(
                    onPressed: () async {
                      final icon = await showIconPicker(context);
                      if (icon != null) {
                        setState(() {
                          selectedIcon = icon;
                        });
                      }
                    },
                    child: Text('Select Icon'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Edit todo'),
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                onChanged: (value) {
                  setState(() {
                    description = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Due date'),
                subtitle: dueDate == null
                    ? null
                    : Text(
                        formatDateTime(dueDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: DateTime.now().isAfter(dueDate!)
                                ? Colors.redAccent
                                : null),
                      ),
                trailing: dueDate == null
                    ? IconButton(
                        onPressed: () async {
                          final isGranted =
                              await _requestNotificationPermission();
                          if (!context.mounted) return;

                          if (!isGranted) {
                            _showPermissionDeniedSnackbar(context);
                            return;
                          }

                          await _initializeNotifications();
                          if (!context.mounted) return;

                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                          );
                          if (!context.mounted) return;

                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(DateTime.now()),
                            );

                            if (pickedTime != null) {
                              final dueDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute,
                              );
                              _setDueDate(widget.todo.id, dueDate);
                              setState(() {
                                this.dueDate = dueDate;
                              });

                              await _scheduleNotification(
                                widget.todo.id,
                                dueDate,
                                widget.todo.text,
                              );
                            }
                          }
                        },
                        icon: Icon(Icons.add),
                      )
                    : IconButton(
                        onPressed: () {
                          _setDueDate(widget.todo.id, null);
                          setState(() {
                            dueDate = null;
                          });
                          _cancelNotification(widget.todo.id);
                        },
                        icon: Icon(Icons.close),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _updateIcon(String todoId, IconData? icon) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .update({
      'icon': icon?.codePoint,
    });
  } catch (e, st) {
    log('Error updating icon', error: e, stackTrace: st);
  }
}

Future<void> _deleteTodo(String todoId) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .delete();
  } catch (e, st) {
    log('Error deleting todo', error: e, stackTrace: st);
  }
}

Future<void> _updateText(String todoId, String text) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .update({
      'text': text,
    });
  } catch (e, st) {
    log('Error updating todo', error: e, stackTrace: st);
  }
}

Future<void> _updateDescription(String todoId, String description) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .update({
      'description': description,
    });
  } catch (e, st) {
    log('Error updating todo', error: e, stackTrace: st);
  }
}

Future<void> _setDueDate(String todoId, DateTime? dueDate) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionTodo)
        .doc(todoId)
        .update({
      'dueDate': dueDate,
    });
  } catch (e, st) {
    log('Error setting due date', error: e, stackTrace: st);
  }
}

Future<bool> _requestNotificationPermission() async {
  final isGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;
  return isGranted;
}

void _showPermissionDeniedSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'You need to enable notifications to set due date.',
        style: Theme.of(context)
            .textTheme
            .bodyMedium
            ?.copyWith(color: Colors.white),
      ),
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 10),
      action: SnackBarAction(
        label: 'Open Settings',
        textColor: Colors.white,
        onPressed: () {
          AppSettings.openAppSettings(
            type: AppSettingsType.notification,
          );
        },
      ),
    ),
  );
}

Future<void> _initializeNotifications() async {
  final initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

Future<void> _scheduleNotification(
  String todoId,
  DateTime dueDate,
  String text,
) async {
  final tzDateTime = tz.TZDateTime.from(dueDate, tz.local);
  await flutterLocalNotificationsPlugin.zonedSchedule(
    todoId.hashCode,
    'Task due',
    text,
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

Future<void> _cancelNotification(String todoId) async {
  await flutterLocalNotificationsPlugin.cancel(todoId.hashCode);
}
