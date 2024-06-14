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

InputDecoration textFieldDecoration(value, icon) {
  return InputDecoration(
    suffixIcon: Icon(icon),
    hintText: 'Enter your $value',
    filled: true,
    fillColor: const Color(0xFFEEEEEE), // Gloomy grey background
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide.none,
    ),
  );
}
