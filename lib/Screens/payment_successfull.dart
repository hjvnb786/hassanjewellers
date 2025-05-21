import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/home.dart';

class PaymentSuccessfull extends StatelessWidget {
  const PaymentSuccessfull({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Payment Successful",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Home()),
                  (Route<dynamic> route) =>
                      false, // This predicate ensures all routes are removed
                );
              },
              child: const Text("Return to Home"),
            )
          ],
        ),
      ),
    );
  }
}
