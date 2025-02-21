import 'package:flutter/material.dart';

// Define a method to get the button style
ButtonStyle elevatedButtonStyle() {
  return ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10), // Adjust the radius as needed
    ),
  );
}

InputDecoration textFieldDecoration(value, icon,
    {bool? prefixEnabled, BuildContext? context}) {
  InputDecoration inputField = InputDecoration(
    //prefix: const Text("+91"),
    suffixIcon: Icon(icon),
    hintText: 'Enter your $value',
    filled: true,
    fillColor: const Color(0xFFEEEEEE), // Gloomy grey background

    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
  );

  // Conditionally add the prefix
  if (prefixEnabled != null && prefixEnabled == true) {
    inputField = inputField.copyWith(
      prefixIcon: const Padding(
        padding: EdgeInsets.all(15.0),
        child: Text(
          "+91",
          style: TextStyle(fontSize: 15),
        ),
      ),
      //prefixText: '+91 ', // Adds "+91" as the prefix text.
    );
  }

  return inputField;
}
