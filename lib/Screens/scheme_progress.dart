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
        ElevatedButton(onPressed: () {}, child: const Text("pay")),
      ],
    );
  }

  List<String> installmentLabels = [
    "First Installment",
    "Second Installment",
    "Third Installment",
    "Fourth Installment",
    "Fifth Installment",
    "Sixth Installment",
    "Seventh Installment",
    "Eighth Installment",
    "Ninth Installment",
    "Tenth Installment",
    "Eleventh Installment",
    "Twelfth Installment",
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> progressList =
        widget.progress.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> element = entry.value;

      String formattedDate = "";

      String getMonthName(int month) {
        const List<String> monthNames = [
          "January",
          "February",
          "March",
          "April",
          "May",
          "June",
          "July",
          "August",
          "September",
          "October",
          "November",
          "December"
        ];
        return monthNames[month - 1]; // Adjust for 0-based indexing
      }

      if (element["date"] != null) {
        Timestamp timestamp = element["date"];
        DateTime dateTime = timestamp.toDate();
        //formattedDate = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
        formattedDate =
            "${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}";
      }

      return {
        'paid': element['paid'],
        'label': installmentLabels[index],
        'date': formattedDate
      };
    }).toList();

    String addOneMonth(String dateString) {
      // Parse the input string to a DateTime object
      DateTime originalDate = DateFormat("dd MMMM yyyy").parse(dateString);

      // Add one month to the date
      DateTime newDate =
          DateTime(originalDate.year, originalDate.month + 1, originalDate.day);

      // Format the new date back to the string format
      return DateFormat("dd MMMM yyyy").format(newDate);
    }

    for (var i = 0; i < progressList.length; i++) {
      if (progressList[i]['paid'] == false) {
        String eligibleDate = addOneMonth(progressList[i - 1]['date']);

        progressList[i]["eligibleDate"] = eligibleDate;

        //progressList[i]['payButton']  = true;
        break;
      }
    }

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
                isActive: item["paid"] ? true : false,
                title: Text(item["label"]),
                subtitle: Text(item['paid'] == true ? "Paid" : "Not Paid"),
                content: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      item['paid'] == true
                          ? Text("Paid on ${(item["date"])}")
                          : ElevatedButton(
                              onPressed:
                                  item["payButton"] == true ? () {} : null,
                              child: Text(item["eligibleDate"] == null
                                  ? "complete your previous payments"
                                  : "You due date is ${item["eligibleDate"]}"),
                            ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
        controlsBuilder: (BuildContext context, ControlsDetails controls) {
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
