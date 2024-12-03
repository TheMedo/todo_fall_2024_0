import 'package:flutter/material.dart';

Future<IconData?> showIconPicker(BuildContext context) async {
  List<IconData> icons = [
    Icons.home,
    Icons.work,
    Icons.shopping_cart,
    Icons.school,
    Icons.favorite,
    Icons.cake,
  ];

  return await showModalBottomSheet<IconData>(
    context: context,
    builder: (BuildContext context) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
        ),
        itemCount: icons.length,
        itemBuilder: (BuildContext context, int index) {
          return IconButton(
            icon: Icon(icons[index]),
            onPressed: () {
              Navigator.pop(context, icons[index]);
            },
          );
        },
      );
    },
  );
}
