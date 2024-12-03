import 'package:flutter/material.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    required this.initialHideCompleted,
    required this.onHideCompleted,
    required this.initialShowPriorityOnly,
    required this.onShowPriorityOnly,
    super.key,
  });

  final bool initialHideCompleted;
  final void Function(bool) onHideCompleted;
  final bool initialShowPriorityOnly;
  final void Function(bool) onShowPriorityOnly;

  @override
  FilterBottomSheetState createState() => FilterBottomSheetState();
}

class FilterBottomSheetState extends State<FilterBottomSheet> {
  late bool hideCompleted;
  late bool showPriorityOnly;

  @override
  void initState() {
    super.initState();
    hideCompleted = widget.initialHideCompleted;
    showPriorityOnly = widget.initialShowPriorityOnly;
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
          title: const Text('Hide completed TODOs'),
          onTap: () {
            setState(() {
              final newValue = !hideCompleted;
              hideCompleted = newValue;
              widget.onHideCompleted(newValue);
            });
          },
        ),
        ListTile(
          leading: IgnorePointer(
            child: Checkbox(
              value: showPriorityOnly,
              onChanged: (value) {},
            ),
          ),
          title: const Text('Show priority TODOs only'),
          onTap: () {
            setState(() {
              final newValue = !showPriorityOnly;
              showPriorityOnly = newValue;
              widget.onShowPriorityOnly(newValue);
            });
          },
        ),
      ],
    );
  }
}
