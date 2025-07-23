import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Helpers/utils.dart';

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
      "progress": generateProgress(),
      "status": true
    });
  });
  return true;
} 