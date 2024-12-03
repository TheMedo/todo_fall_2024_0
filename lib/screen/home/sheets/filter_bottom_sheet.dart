import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    required this.initialHideCompleted,
    required this.onHideCompleted,
    required this.initialSortOption,
    required this.onSortOptionChanged,
    super.key,
  });

  final bool initialHideCompleted;
  final void Function(bool) onHideCompleted;
  final String initialSortOption;
  final void Function(String) onSortOptionChanged;

  @override
  _FilterBottomSheetState createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late bool hideCompleted;
  late String selectedSortOption;

  @override
  void initState() {
    super.initState();
    hideCompleted = widget.initialHideCompleted;
    selectedSortOption = widget.initialSortOption;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        ListTile(
          title: Text('Sort by'),
          trailing: DropdownButton<String>(
            value: selectedSortOption,
            items: [
              DropdownMenuItem(
                value: 'timestamp',
                child: Text('Timestamp'),
              ),
              DropdownMenuItem(
                value: 'priority',
                child: Text('Priority'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onSortOptionChanged(value);
                setState(() {
                  selectedSortOption = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
