import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:hassanjewellers/Screens/account.dart';
import 'package:hassanjewellers/Screens/schemes.dart';
import 'package:hassanjewellers/Screens/new_scheme.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  List<Widget> screens = [
    const Schemes(),
    const NewScheme(),
    const Account(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: GNav(
        padding: EdgeInsetsGeometry.infinity,
        backgroundColor: Colors.brown,
        onTabChange: (index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        tabs: const [
          GButton(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(15),
            iconColor: Colors.white,
            icon: Icons.home,
            text: "Home",
            gap: 8,
          ),
          GButton(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(15),
            iconColor: Colors.white,
            icon: Icons.inventory_sharp,
            text: "installments",
            gap: 8,
          ),
          GButton(
            backgroundColor: Colors.white,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.all(15),
            iconColor: Colors.white,
            icon: Icons.account_box,
            text: "account",
            gap: 8,
          ),
        ],
      ),
    );
  }
}
