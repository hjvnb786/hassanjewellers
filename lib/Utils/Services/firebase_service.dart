import 'package:cloud_firestore/cloud_firestore.dart';

Future<bool> checkPhoneExists(String fieldValue) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where("phone", isEqualTo: fieldValue)
      .limit(1)
      .get();
  return querySnapshot.docs.isNotEmpty;
}