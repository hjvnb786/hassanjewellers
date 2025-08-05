import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> registerUser(
    String uid, String firstName, String lastName, String phone, String email) async {
  await FirebaseFirestore.instance
      .collection("users")
      .add({
        "uid": uid, 
        "phone": phone, 
        "firstName": firstName, 
        "lastName": lastName, 
        "email": email
      });

  return true;
} 