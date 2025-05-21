import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/payment.dart';
import 'package:hassanjewellers/Utils/Helpers/utils.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';

class SchemeProgress extends StatefulWidget {
  final String id;
  final List<dynamic> progress;
  final String amount;
  final String name;

  const SchemeProgress(
      {super.key,
      required this.progress,
      required this.id,
      required this.amount,
      required this.name});

  @override
  State<SchemeProgress> createState() => _SchemeProgressState();
}

class _SchemeProgressState extends State<SchemeProgress> {
  int currentStep = 0;
  late List<Map<String, dynamic>> progressList;
  bool enableButton = true;

  Widget controlsBuilder(context, details, {data}) {
    return Row(
      children: [
        ElevatedButton(onPressed: () {}, child: const Text("pay")),
      ],
    );
  }

  void handlePay() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Payment(
                id: widget.id,
                amount: widget.amount,
                name: widget.name,
              )),
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
  void initState() {

    super.initState();
    print("It is doc Id I think: ${widget.id}");
    progressList = getProgressList(widget.progress);

    print("progressList in scheme_progress $progressList");

  }

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < progressList.length; i++) {
      if (progressList[i]['paid'] == false) {
        progressList[i]['payButton'] = true;
        break;
      }
    }

    print("progress list");
    print(progressList);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Scheme Progress"),
      ),
      body: Stepper(
        type: StepperType.vertical,
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
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Paid on ${(item["date"])}"),
                                const Text("Paid by UPI"),
                                Text("Reference ID: ${(item["referenceId"])}")
                              ],
                            )
                          : enableButton
                              ? ElevatedButton(
                                  onPressed: item["payButton"] == true
                                      ? handlePay
                                      : null,
                                  child: const Text("Pay"),
                                )
                              : const SizedBox(
                                  width: 100,
                                  child: LinearProgressIndicator(),
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
