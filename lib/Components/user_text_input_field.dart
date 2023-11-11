import 'package:flutter/material.dart';

class UserTextInputField extends StatelessWidget {
  final String label;
  final TextEditingController textController;

  const UserTextInputField(
      {super.key, required this.label, required this.textController});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
            TextField(
              controller: textController,
              style: const TextStyle(),
              decoration: const InputDecoration(hintText: "Your answer"),
            ),
          ],
        ),
      ),
    );
  }
}
