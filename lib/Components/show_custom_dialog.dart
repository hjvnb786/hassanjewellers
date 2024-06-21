import 'package:flutter/material.dart';

void showCustomDialog(
    BuildContext context, String headerText, String bodyContent) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(headerText),
        content: Text(bodyContent),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
