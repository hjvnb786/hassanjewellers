import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/account.dart';
import 'package:hassanjewellers/Screens/schemes.dart';
import 'package:hassanjewellers/Screens/new_scheme.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;
  late Future<dynamic> userAccountDetails;
  String customerName = "";
  String customerPhone = "";
  String customerEmail = "";

  @override
  void initState() {
    super.initState();
    userAccountDetails = getDocumentByUid(uid, "users");
    userAccountDetails.then((value) => {
          setState(() {
            customerName = value["name"];
            customerPhone = value["phone"];
            customerEmail = value["email"];
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const Schemes(),
      const NewScheme(),
      Account(name: customerName, phone: customerPhone, email: customerEmail),
    ];

    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentPageIndex,
        onTap: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: "New"),
          BottomNavigationBarItem(
              icon: Icon(Icons.account_box), label: "Profile"),
        ],
      ),
    );
  }
}
