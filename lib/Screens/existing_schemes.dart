import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/scheme_item.dart';

class ExistingSchemes extends StatefulWidget {
  const ExistingSchemes({super.key});

  @override
  State<ExistingSchemes> createState() => _ExistingSchemesState();
}

class _ExistingSchemesState extends State<ExistingSchemes> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Existing Schemes"),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection("savings")
              .where("userId",
                  isEqualTo: FirebaseAuth.instance.currentUser!.uid.toString())
              .snapshots(),
          builder: (context, snapshot) {
            final schemes = snapshot.data?.docs;
            if (schemes != null) {
              return ListView(
                  children: schemes
                      .map((data) => SchemeItem(
                            name: data["name"],
                            amount: data["installmentAmount"],
                            progress: data["progress"],
                          ))
                      .toList());
            } else {
              return const LinearProgressIndicator();
            }
          },
        ));
  }
}
