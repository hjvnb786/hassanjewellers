import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> registerUser(
    String uid, String name, String phone, String email) async {
  await FirebaseFirestore.instance
      .collection("users")
      .add({"uid": uid, "phone": phone, "name": name, "email": email});

  return true;
} 