import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Helpers/utils.dart';

Future<dynamic> updateProgressItem(id, referenceId, [Map<String, dynamic>? paymentResponse, String? orderId]) async {
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
      // Get the document data
      final docData = querySnapshot.docs[indexMatch].data() as Map<String, dynamic>;
      
      // Access the new nested structure
      final schemeProgress = docData["schemeProgress"] as Map<String, dynamic>? ?? {};
      List<dynamic> installments = schemeProgress["installments"] ?? [];
      
      final progressLength = installments.length; // Get actual progress length
      print("📊 Progress length: $progressLength");

      final getDate = await getAccurateTime().then((time) => time);

      // Use actual progress length instead of hardcoded 12
      for (int i = 0; i < progressLength; i++) {
        print("job done ya index number $i");

        if (i == progressLength - 1) { // Check if it's the last month
          print("job done ya habibi");
          schemeStatus = false;
        }

        if (installments[i]["paid"] == false) {
          installments[i]["paid"] = true;
          installments[i]["date"] = getDate;
          // Note: referenceId is now stored within paymentResponse, not as separate field
          
          // Store the complete payment response if provided
          if (paymentResponse != null) {
            installments[i]["paymentResponse"] = paymentResponse;
            print("✅ Payment response stored in progress month $i");
            print("📊 Payment response data: $paymentResponse");
            print("🔍 Progress month $i now contains: ${installments[i]}");
          } else {
            print("⚠️ No payment response provided for progress month $i");
          }
          break;
        }
      }

      print("updated installments: $installments");

      String documentID = querySnapshot.docs[indexMatch].id;

      // Update the nested structure
      Map<String, dynamic> updateData = {
        'schemeProgress.installments': installments,
        'status': schemeStatus,
      };
      
      // Add order ID if provided
      if (orderId != null) {
        updateData['orderId'] = orderId;
      }
      
      await collectionRef.doc(documentID).update(updateData);

      return await collectionRef
          .doc(documentID)
          .get()
          .then((value) {
            final data = value.data() as Map<String, dynamic>?;
            return data?["schemeProgress"]?["installments"];
          });
    } else {
      print('No document found with the specified criteria');
    }
  } catch (error) {
    print('Error updating progress item: $error');
  }
  return null;
}


