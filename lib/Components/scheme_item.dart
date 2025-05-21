import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/scheme_progress.dart';

class SchemeItem extends StatelessWidget {
  final String id;
  final String name;
  final String amount;
  final List<dynamic> progress;

  const SchemeItem(
      {super.key,
      required this.id,
      required this.name,
      required this.amount,
      required this.progress});

  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SchemeProgress(
        id: id,
        progress: progress,
        amount: amount,
        name: name,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int progressNumber = 0;

    for (var element in progress) {
      if (element["paid"] == true) {
        progressNumber++;
      }
    }

    print("progress in scheme_item $progress");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 0,
        color: const Color(0xFFEEEEEE),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progressNumber / 12,
                    minHeight: 10,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    name,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    amount,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(createRoute());
              },
              child: const Text("View Progress"),
            )
          ],
        ),
      ),
    );
  }
}
