import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Utils/Helpers/utils.dart';

Future<dynamic> updateProgressItem(id, referenceId) async {
  try {
    // Get the unique identifier (uid) of the currently authenticated user
    final uid = FirebaseAuth.instance.currentUser?.uid;
    bool schemeStatus = true;

    // Create a reference to the 'savings' collection in Firestore
    CollectionReference collectionRef =
        FirebaseFirestore.instance.collection('savings');

    // Query the 'savings' collection for documents where the 'userId' field is equal to the current user's uid
    QuerySnapshot querySnapshot =
        await collectionRef.where("userId", isEqualTo: uid).get();

    int prog = querySnapshot.docs.length;
    print("hello world");
    print("id: " + id);
    print(prog);

    int indexMatch = 00000;

    for (var i = 0; i < prog; i++) {
      print(querySnapshot.docs[i].id);
      if (querySnapshot.docs[i].id == id) {
        print("match");
        indexMatch = i;
      }
    }

    if (querySnapshot.docs.isNotEmpty) {
      List<dynamic> progress = querySnapshot.docs[indexMatch]["progress"];

      final getDate = await getAccurateTime().then((time) => time);

      for (int i = 0; i < 12; i++) {
        print("job done ya index number $i");

        if (i == 11) {
          print("job done ya habibi");
          schemeStatus = false;
        }

        if (progress[i]["paid"] == false) {
          progress[i]["paid"] = true;
          progress[i]["date"] = getDate;
          progress[i]["referenceId"] = referenceId;
          break;
        }
      }

      print("updated progress: $progress");

      String documentID = querySnapshot.docs[indexMatch].id;

      await collectionRef.doc(documentID).update({
        'progress': progress,
        'status': schemeStatus,
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