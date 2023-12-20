import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Utils/Helpers/utils.dart';

Future<bool> checkPhoneExists(String fieldValue) async {
  final querySnapshot = await FirebaseFirestore.instance
      .collection('users')
      .where("phone", isEqualTo: fieldValue)
      .limit(1)
      .get();
  return querySnapshot.docs.isNotEmpty;
}

Future<List> getAccountDetails(uid) async {
  final getDetails = await FirebaseFirestore.instance
      .collection("users")
      .where("uid", isEqualTo: uid)
      .get()
      .then((value) {
    return [
      value.docs.first.get("name"),
      value.docs.first.get("email"),
      value.docs.first.get("phone")
    ];
  });

  return getDetails;
}

Future<bool> addNewScheme(
  String name,
  String monthlySelectedAmount,
  String guardianName,
  String occupation,
  String nomineeName,
  String nomineeRelation,
  String address,
  String age,
) async {
  getAccurateTime().then((time) {
    FirebaseFirestore.instance.collection("savings").add({
      "userId": FirebaseAuth.instance.currentUser!.uid.toString(),
      "name": name,
      "installmentAmount": monthlySelectedAmount,
      "guardianName": guardianName,
      "occupation": occupation,
      "nomineeName": nomineeName,
      "nomineeRelation": nomineeRelation,
      "address": address,
      "age": age,
      "date": time,
      "progress": generateProgress()
    });
  });
  return true;
}
