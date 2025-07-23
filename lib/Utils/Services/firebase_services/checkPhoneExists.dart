import 'package:cloud_firestore/cloud_firestore.dart';

Future<String> checkPhoneExists(String fieldValue) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where("phone", isEqualTo: fieldValue)
      .limit(1)
      .get();

  if (querySnapshot.docs.isEmpty) {
    return "";
  }

  return querySnapshot.docs.first["uid"];
} 