import 'package:flutter/material.dart';

class AccountDetailsCard extends StatelessWidget {
  const AccountDetailsCard(
      {super.key, required this.name, required this.title});

  final String name;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),

        ListTile(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10), // Adjust the radius as needed
          ),
          selectedTileColor: const Color(0xFFEEEEEE),
          selectedColor: Colors.grey[900],
          titleTextStyle:
              const TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
          selected: true,
          title: Text(name),
        ),
      ],
    );
  }
}
