import 'dart:developer';

import 'package:app_settings/app_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:todo_fall_2024_0/data/model/todo.dart';
import 'package:todo_fall_2024_0/screen/home/home_screen.dart';

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

  String? text;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    text = widget.todo.text;
    dueDate = widget.todo.dueDate;
    _controller = TextEditingController(text: text);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              TextField(
                controller: _controller,
                decoration: InputDecoration(labelText: 'Edit todo'),
                onChanged: (value) {
                  setState(() {
                    text = value;
                  });
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Due date'),
                subtitle: dueDate == null ? null : Text(dueDate?.toString() ?? ''),
                trailing: dueDate == null
                    ? IconButton(
                        onPressed: () async {
                          final isGranted = await _requestNotificationPermission();
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
                              initialTime: TimeOfDay.fromDateTime(DateTime.now()),
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
    log('Error updating todo', error: e, stackTrace: st);
  }
}

Future<void> _setDueDate(String todoId, DateTime? dueDate) async {
  try {
    await FirebaseFirestore.instance.collection(collectionTodo).doc(todoId).update({
      'dueDate': dueDate,
    });
  } catch (e, st) {
    log('Error setting due date', error: e, stackTrace: st);
  }
}

Future<bool> _requestNotificationPermission() async {
  final isGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission() ??
      false;
  return isGranted;
}

void _showPermissionDeniedSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'You need to enable notifications to set due date.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
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
  final initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
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
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}

Future<void> _cancelNotification(String todoId) async {
  await flutterLocalNotificationsPlugin.cancel(todoId.hashCode);
}
