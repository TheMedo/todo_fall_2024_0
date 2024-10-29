import 'package:flutter/material.dart';

class TextInputRow extends StatefulWidget {
  final void Function(String) onAdd;

  const TextInputRow({super.key, required this.onAdd});

  @override
  _TextInputRowState createState() => _TextInputRowState();
}

class _TextInputRowState extends State<TextInputRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Enter your todo',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              prefixIcon: Icon(Icons.edit_outlined),
            ),
          ),
        ),
        SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isNotEmpty) {
              widget.onAdd(_controller.text);
              _controller.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            fixedSize: const Size(88, 54),
          ),
          child: Text('Add'),
        ),
      ],
    );
  }
}
