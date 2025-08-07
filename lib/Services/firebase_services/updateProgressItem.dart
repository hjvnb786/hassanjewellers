import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Helpers/utils.dart';

Future<dynamic> updateProgressItem(id, referenceId, [Map<String, dynamic>? paymentResponse]) async {
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
    print("🔍 Looking for scheme with ID: $id");
    print("📊 Found $prog schemes for user");

    int indexMatch = -1; // Initialize to -1 to indicate no match found

    for (var i = 0; i < prog; i++) {
      String docId = querySnapshot.docs[i].id;
      print("📋 Document $i ID: $docId");
      
      if (docId == id) {
        print("✅ Exact match found at index $i");
        indexMatch = i;
        break; // Exit loop once match is found
      }
    }

    // If no exact match found, try to find by other criteria
    if (indexMatch == -1) {
      print("⚠️ No exact match found, trying partial match...");
      // You might want to add additional matching logic here
      // For now, let's use the first document if only one exists
      if (prog == 1) {
        print("📋 Using the only available scheme");
        indexMatch = 0;
      } else {
        print("❌ No matching scheme found");
        throw Exception("No matching scheme found in Firestore");
      }
    }

    if (querySnapshot.docs.isNotEmpty && indexMatch >= 0) {
      // Get the document data
      final docData = querySnapshot.docs[indexMatch].data() as Map<String, dynamic>;
      print("📄 Successfully retrieved document data for scheme");
      
      // Debug: Print all available fields in the document
      print("🔍 Document data fields: ${docData.keys.toList()}");
      print("📄 Full document data: $docData");
      
      // Access the new nested structure
      final schemeProgress = docData["schemeProgress"] as Map<String, dynamic>? ?? {};
      List<dynamic> installments = schemeProgress["installments"] ?? [];
      
      final progressLength = installments.length; // Get actual progress length
      print("📊 Progress length: $progressLength");

      // Get the base order ID from when the scheme was created
      // Check multiple possible locations for orderId
      String baseOrderId = docData["schemeDetails"]?["orderId"] ?? 
                          docData["orderId"] ?? 
                          docData["referenceId"] ?? 
                          "RA5000";
      
      print("📋 Base order ID: $baseOrderId");

      // Count how many installments are already paid
      int paidInstallments = 0;
      for (var installment in installments) {
        if (installment["paid"] == true) {
          paidInstallments++;
        }
      }
      print("💰 Paid installments count: $paidInstallments");

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
          
          // Generate new order ID with incrementing suffix
          String newOrderId = "$baseOrderId-${paidInstallments + 1}";
          print("🆔 Generated new order ID: $newOrderId for installment $i");
          
          // Store the complete payment response if provided
          if (paymentResponse != null) {
            // Create updated payment response with new order ID
            Map<String, dynamic> updatedPaymentResponse = Map<String, dynamic>.from(paymentResponse);
            updatedPaymentResponse["orderId"] = newOrderId;
            
            installments[i]["paymentResponse"] = updatedPaymentResponse;
            print("✅ Updated payment response stored in progress month $i");
            print("📊 Updated payment response data: $updatedPaymentResponse");
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
      
      // Increment installment count for existing schemes
      final currentInstallmentCount = docData['installmentCount'] as int? ?? 0;
      updateData['installmentCount'] = currentInstallmentCount + 1;
      
      print("📊 Incrementing installment count: $currentInstallmentCount -> ${currentInstallmentCount + 1}");
      
      await collectionRef.doc(documentID).update(updateData);

      return await collectionRef
          .doc(documentID)
          .get()
          .then((value) {
            final data = value.data() as Map<String, dynamic>?;
            return data?["schemeProgress"]?["installments"];
          });
    } else {
      print('❌ No document found with the specified criteria');
      print('📊 Available documents: ${querySnapshot.docs.length}');
      if (querySnapshot.docs.isNotEmpty) {
        print('📋 Document IDs: ${querySnapshot.docs.map((doc) => doc.id).toList()}');
      }
    }
  } catch (error) {
    print('Error updating progress item: $error');
  }
  return null;
}


