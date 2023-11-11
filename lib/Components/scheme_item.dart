import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/scheme_progress.dart';

class SchemeItem extends StatelessWidget {
  final String name;
  final String amount;
  final List<dynamic> progress;

  const SchemeItem(
      {super.key,
      required this.name,
      required this.amount,
      required this.progress});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w300),
                ),
                Text(
                  amount,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => SchemeProgress(progress: progress)));
            },
            child: const Text("View Progress"),
          )
        ],
      ),
    );
  }
}
