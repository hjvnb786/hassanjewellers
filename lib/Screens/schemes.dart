import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/scheme_item.dart';

class Schemes extends StatefulWidget {
  const Schemes({super.key});

  @override
  State<Schemes> createState() => _SchemesState();
}

class _SchemesState extends State<Schemes> with TickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Existing Schemes"),
          bottom: TabBar(
            controller: _tabController,
            tabs: const <Widget>[
              Tab(text: "Active"),
              Tab(text: "Closed"),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            Scaffold(
              body: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("savings")
                    .where("userId",
                        isEqualTo:
                            FirebaseAuth.instance.currentUser!.uid.toString())
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
              ),
            ),
            const Center(child: Text("Closed"))
          ],
        ));
  }
}
