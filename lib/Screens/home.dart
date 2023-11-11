import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/existing_schemes.dart';
import 'package:hassanjewellers/Screens/new_scheme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NewScheme(),
                    ),
                  );
                },
                child: const Text("New Savings Scheme"),
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ExistingSchemes(),
                    ),
                  );
                },
                child: const Text("Existing Savings Scheme"),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
