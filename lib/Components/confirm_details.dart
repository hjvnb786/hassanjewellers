import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
    BuildContext context,
    String name,
    String guardianName,
    String nomineeName,
    String address,
    String age,
    String alternateMobile,
    ) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Review Submitted Information"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildConfirmationRow("Name", name),
            buildConfirmationRow("Guardian Name", guardianName),
            buildConfirmationRow("Nominee Name", nomineeName),
            buildConfirmationRow("Address", address),
            buildConfirmationRow("Age", age),
            buildConfirmationRow("Alternate Mobile", alternateMobile),
            // Add more lines for other fields as needed
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              // Call the function to submit the data or perform further actions
              //submitData();
            },
            child: const Text("Confirm"),
          ),
        ],
      );
    },
  );
}

Widget buildConfirmationRow(String label, String value) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                value,
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
      const Divider(), // Add a Divider between fields
    ],
  );
}
