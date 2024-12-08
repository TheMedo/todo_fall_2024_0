import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/model/todo.dart';

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

// In your DetailsScreen class, update the color options list like this:
  final List<Color?> _colorOptions = [  // Change the type to List<Color?>
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
    _descriptionController = TextEditingController(text: widget.todo.description);
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
                  child: Text(_dueDate == null
                      ? 'Select Date'
                      : '${_dueDate!.month}/${_dueDate!.day}/${_dueDate!.year}'),
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
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

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating todo')),
      );
    }
  }
}