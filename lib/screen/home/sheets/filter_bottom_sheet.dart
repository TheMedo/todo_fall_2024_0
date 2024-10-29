import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    required this.initialHideCompleted,
    required this.onHideCompleted,
    super.key,
  });

  final bool initialHideCompleted;
  final void Function(bool) onHideCompleted;

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late bool hideCompleted;

  @override
  void initState() {
    super.initState();
    hideCompleted = widget.initialHideCompleted;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          leading: IgnorePointer(
            child: Checkbox(
              value: hideCompleted,
              onChanged: (value) {},
            ),
          ),
          title: Text('Hide completed TODOs'),
          onTap: () {
            setState(() {
              final newValue = !hideCompleted;
              hideCompleted = newValue;
              widget.onHideCompleted(newValue);
            });
          },
        ),
      ],
    );
  }
}
