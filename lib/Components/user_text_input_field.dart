import 'package:flutter/material.dart';

class UserTextInputField extends StatelessWidget {
  final String label;
  final TextEditingController textController;
  final String? Function(String?) validationCriteria;
  final bool? isNumber;

  const UserTextInputField(
      {super.key,
      required this.label,
      required this.textController,
      required this.validationCriteria,
      this.isNumber = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
            TextFormField(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: validationCriteria,
              controller: textController,
              style: const TextStyle(),
              keyboardType: isNumber! ? TextInputType.phone : TextInputType.text,
              decoration: const InputDecoration(hintText: "Your answer"),
            ),
          ],
        ),
      ),
    );
  }
}
