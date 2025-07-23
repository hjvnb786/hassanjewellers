import 'package:firebase_auth/firebase_auth.dart';

Future<UserCredential> signInWithCustomToken(String token) async {
  return await FirebaseAuth.instance.signInWithCustomToken(token);
} 