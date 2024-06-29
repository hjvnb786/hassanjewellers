import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context,
  String amount,
  String name,
  String guardianName,
  String occupation,
  String nomineeName,
  String nomineeRelationship,
  String address,
  String age,
  String alternateMobile,
) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: const Color(0xFFEEEEEE),
        title: const Text("Review Submitted Information"),
        content: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildConfirmationRow("Installment Amount", amount),
                buildConfirmationRow("Name", name),
                buildConfirmationRow("Guardian Name", guardianName),
                buildConfirmationRow("Occupation", occupation),
                buildConfirmationRow("Nominee Name", nomineeName),
                buildConfirmationRow(
                    "Relationship with Nominee", nomineeRelationship),
                buildConfirmationRow("Address", address),
                buildConfirmationRow("Age", age),
                buildConfirmationRow("Mobile Number", alternateMobile),
                // Add more lines for other fields as needed
              ],
            ),
          ),
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
            child: const Text("Continue to Payment"),
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              width: 10,
            ),
            Flexible(
              child: Text(
                value,
                softWrap: true,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
      const Divider(), // Add a Divider between fields
    ],
  );
}
