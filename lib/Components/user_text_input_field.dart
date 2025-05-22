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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: validationCriteria,
            controller: textController,
            style: const TextStyle(fontSize: 16),
            keyboardType: isNumber! ? TextInputType.phone : TextInputType.text,
            decoration: InputDecoration(
              hintText: "Your answer",
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
