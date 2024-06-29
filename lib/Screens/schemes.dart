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
  final uid = FirebaseAuth.instance.currentUser?.uid;
  late Stream<QuerySnapshot<Map<String, dynamic>>> activeSchemeList;
  late Stream<QuerySnapshot<Map<String, dynamic>>> closedSchemeList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    activeSchemeList = _firestore
        .collection("savings")
        .where("userId", isEqualTo: uid)
        .where("status", isEqualTo: true)
        .snapshots();

    closedSchemeList = _firestore
        .collection("savings")
        .where("userId", isEqualTo: uid)
        .where("status", isEqualTo: false)
        .snapshots();
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
                stream: activeSchemeList,
                builder: (context, snapshot) {
                  final schemes = snapshot.data?.docs;
                  if (schemes != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView(children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ...schemes
                            .map((data) => SchemeItem(
                                  id: data.id,
                                  name: data["name"],
                                  amount: data["installmentAmount"],
                                  progress: data["progress"],
                                ))
                            .toList(),
                        const SizedBox(
                          height: 10,
                        ),
                      ]),
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            ),
            Scaffold(
              body: StreamBuilder<QuerySnapshot>(
                stream: closedSchemeList,
                builder: (context, snapshot) {
                  final schemes = snapshot.data?.docs;
                  if (schemes != null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ListView(children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ...schemes
                            .map((data) => SchemeItem(
                                  id: data.id,
                                  name: data["name"],
                                  amount: data["installmentAmount"],
                                  progress: data["progress"],
                                ))
                            .toList(),
                        const SizedBox(
                          height: 10,
                        ),
                      ]),
                    );
                  } else {
                    return const LinearProgressIndicator();
                  }
                },
              ),
            ),
          ],
        ));
  }
}
