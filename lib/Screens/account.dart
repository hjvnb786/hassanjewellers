import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/main.dart';

class Account extends StatelessWidget {
  Account({super.key});

  @override
  Widget build(BuildContext context) {
    final name = FirebaseAuth.instance.currentUser?.phoneNumber;

    String? setName = "";

    if (name != null) {
      print(name);
      setName = name;
    }

    print(name);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          Card(child: ListTile(title: Text('Kaki Mohammed Tuaha'))),
          Card(child: ListTile(title: Text('9944266275'))),
          Card(child: ListTile(title: Text('tuahakst@gmail.com'))),

          ListTile(
            title: Text(
              'Log out',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await FirebaseAuth.instance.signOut();


              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MyApp()),
                    (Route<dynamic> route) => false, // This predicate ensures all routes are removed
              );
              // Navigator.of(context).push(
              //   MaterialPageRoute(
              //     builder: (context) => MyApp(),
              //   ),
              // ); // Added semicolon
            },
          ),

          // More Options Section
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('More Options',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: Text('Share'),
            onTap: () {/* Implement Share Functionality */},
          ),
          ListTile(
            title: Text('About Us'),
            onTap: () {/* Navigate to About Us Page */},
          ),
        ],
      ),
    );
  }
}
