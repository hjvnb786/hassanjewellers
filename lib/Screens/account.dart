import 'package:cloud_firestore/cloud_firestore.dart';
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
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;



    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: ListView(
        children: [
          Card(child: ListTile(title: Text("taha"))),
          Card(child: ListTile(title: Text("asf"))),
          Card(child: ListTile(title: Text("asfsadf"))),

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
                (Route<dynamic> route) =>
                    false, // This predicate ensures all routes are removed
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
