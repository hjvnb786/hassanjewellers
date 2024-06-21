import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/AccountDetailsCard.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';
import 'package:hassanjewellers/main.dart';

class Account extends StatefulWidget {
  const Account(
      {super.key,
      required this.name,
      required this.phone,
      required this.email});

  final String name;
  final String phone;
  final String email;

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            AccountDetailsCard(name: widget.name, title: "Name"),
            AccountDetailsCard(name: widget.phone, title: "Phone"),
            AccountDetailsCard(name: widget.email, title: "Email"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text(
                          "Are you sure you want to log out?",
                          style: TextStyle(fontSize: 20),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text(
                              'Log Out',
                              style: TextStyle(color: Colors.red),
                            ),
                            onPressed: () async {
                              await FirebaseAuth.instance
                                  .signOut()
                                  .then((value) {})
                                  .whenComplete(
                                      () => Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => MyApp()),
                                            (Route<dynamic> route) =>
                                                false, // This predicate ensures all routes are removed
                                          ));
                            },
                          ),
                        ],
                      );
                    });
              },
              style: elevatedButtonStyle(),
              child: const Text(
                'LOG OUT',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
