import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SchemeProgress extends StatefulWidget {
  final List<dynamic> progress;

  const SchemeProgress({super.key, required this.progress});

  @override
  State<SchemeProgress> createState() => _SchemeProgressState();
}

class _SchemeProgressState extends State<SchemeProgress> {
  int currentStep = 0;

  Widget controlsBuilder(context, details, {data}) {
    return Row(
      children: [
        ElevatedButton(onPressed: () {
        }, child: const Text("pay")),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> progressList = widget.progress.map((element) {
      Timestamp timestamp = element["date"];
      DateTime dateTime = timestamp.toDate();
      return {
        'date': DateFormat("MMMM d, y").format(dateTime),
        'paid': element['paid']
      };
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheme Progress"),
      ),
      body: Stepper(
        currentStep: currentStep,
        onStepTapped: (value) {
          setState(() {
            currentStep = value;
          });
        },
        steps: progressList
            .map(
              (item) => Step(
                title: Text(item['date']),
                subtitle: Text(item['paid'] == true ? "Paid" : "Not Paid"),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(item['paid'] == true
                          ? "Paid on November 11, 2023 at${item["paidDate"]}"
                          : "Not Paid"),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
        controlsBuilder: controlsBuilder,
      ),
    );
  }
}
