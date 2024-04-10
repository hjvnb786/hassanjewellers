import 'package:flutter/material.dart';
import 'package:hassanjewellers/Utils/Helpers/utils.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';

class SchemeProgress extends StatefulWidget {
  final List<dynamic> progress;

  const SchemeProgress({super.key, required this.progress});

  @override
  State<SchemeProgress> createState() => _SchemeProgressState();
}

class _SchemeProgressState extends State<SchemeProgress> {
  int currentStep = 0;
  late List<Map<String, dynamic>> progressList;

  Widget controlsBuilder(context, details, {data}) {
    return Row(
      children: [
        ElevatedButton(onPressed: () {}, child: const Text("pay")),
      ],
    );
  }

  void handlePay() {
    updateProgressItem().then((value) {
      if (value != null) {
        setState(() {
          progressList = getProgressList(value);
        });
      }
    });
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
  void initState() {
    super.initState();
    progressList = getProgressList(widget.progress);
  }

  @override
  Widget build(BuildContext context) {

    for (var i = 0; i < progressList.length; i++) {
      if (progressList[i]['paid'] == false) {
        progressList[i]['payButton'] = true;
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
                                  item["payButton"] == true ? handlePay : null,
                              child: const Text("Pay"),
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
