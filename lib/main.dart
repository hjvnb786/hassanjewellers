import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/home.dart';
import 'package:hassanjewellers/Screens/register.dart';

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
        theme: ThemeData(
          colorScheme: const ColorScheme(
              background: Colors.brown,
              brightness: Brightness.light,
              primary: Colors.brown,
              onPrimary: Colors.white,
              secondary: Colors.orange,
              onSecondary: Colors.white,
              error: Colors.brown,
              onError: Colors.brown,
              onBackground: Colors.red,
              surface: Colors.brown,
              onSurface: Colors.brown),
        ),
        home: currentUser != null && currentUser!.uid.isNotEmpty
            ? const Home()
            : const Register());
  }
}
