import 'dart:async';
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

Future<dynamic> updateProgressItem() async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('savings');
    QuerySnapshot querySnapshot =
        await collectionRef.where("userId", isEqualTo: uid).get();

    if (querySnapshot.docs.isNotEmpty) {
      List<dynamic> progress = querySnapshot.docs.first["progress"];


      final getDate = await getAccurateTime().then((time) => time);

      for (int i = 0; i < 12; i++) {
        if (progress[i]["paid"] == false) {
          progress[i]["paid"] = true;
          progress[i]["date"] = getDate;
          break;
        }
      }
      String documentID = querySnapshot.docs.first.id;

      await collectionRef.doc(documentID).update({
        'progress': progress,
      });

      return await collectionRef
          .doc(documentID)
          .get()
          .then((value) => value["progress"]);
    } else {
      print('No document found with the specified criteria');
    }
  } catch (error) {
    print('Error updating third index: $error');
  }
  return null;
}

Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getDocumentByUid(
    String? uid) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where("uid", isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first;
  } catch (e) {
    return null;
  }
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
