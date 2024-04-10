import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';
import 'package:hassanjewellers/main.dart';

class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  String name = "taha";
  String phone = "taha";
  String email = "taha";

  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: FutureBuilder<dynamic>(
        future: getDocumentByUid(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LinearProgressIndicator();
          }
          return ListView(
            children: [
              Card(child: ListTile(title: Text(snapshot.data["name"] ?? ""))),
              Card(child: ListTile(title: Text(snapshot.data["phone"] ?? ""))),
              Card(child: ListTile(title: Text(snapshot.data["email"] ?? ""))),
              ListTile(
                title: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  await FirebaseAuth.instance.signOut().then((value) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MyApp()),
                      (Route<dynamic> route) =>
                          false, // This predicate ensures all routes are removed
                    );
                  });
                },
              ),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('More Options',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                title: const Text('Share'),
                onTap: () {/* Implement Share Functionality */},
              ),
              ListTile(
                title: const Text('About Us'),
                onTap: () {/* Navigate to About Us Page */},
              ),
              ListTile(
                title: const Text('Share the App'),
                onTap: () {/* Navigate to About Us Page */},
              ),
              ListTile(
                title: const Text('Rate Us'),
                onTap: () {/* Navigate to About Us Page */},
              ),
            ],
          );
        },
      ),
    );
  }
}
