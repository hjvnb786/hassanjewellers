import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/account.dart';
import 'package:hassanjewellers/Screens/schemes.dart';
import 'package:hassanjewellers/Screens/join_new_scheme.dart';
import 'package:hassanjewellers/Services/firebase_services/getDocumentByUid.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;
  final String? uid = getCurrentUser()?.uid;
  late Future<QueryDocumentSnapshot<Map<String, dynamic>>?> userAccountDetails;
  String customerName = "";
  String customerPhone = "";
  String customerEmail = "";

  @override
  void initState() {
    super.initState();
    userAccountDetails = getDocumentByUid(uid, "users");
    userAccountDetails.then((doc) {
      if (doc != null) {
        final data = doc.data();
        setState(() {
          customerName = data["name"] ?? "";
          customerPhone = data["phone"] ?? "";
          customerEmail = data["email"] ?? "";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> screens = [
      const Schemes(),
      const JoinNewScheme(),
      Account(name: customerName, phone: customerPhone, email: customerEmail),
    ];

    return Scaffold(
      body: screens[currentPageIndex],
      bottomNavigationBar: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Schemes',
                  index: 0,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.add_circle_outline,
                  label: 'New',
                  index: 1,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  index: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = currentPageIndex == index;
    return InkWell(
      onTap: () => setState(() => currentPageIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                size: 22,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
