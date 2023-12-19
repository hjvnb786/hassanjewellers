import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/home.dart';
import 'package:hassanjewellers/Screens/register.dart';
import 'package:hassanjewellers/Utils/UI/theme_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData,
        home: currentUser != null && currentUser!.uid.isNotEmpty
            ? const Home()
            : const Register());
  }
}
