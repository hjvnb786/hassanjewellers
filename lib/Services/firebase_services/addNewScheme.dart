import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Helpers/utils.dart';

Future<String?> addNewScheme(Map<String, dynamic> schemeData) async {
  try {

    // Extract data from schemeData
    final firstName = schemeData['firstName']?.toString().trim() ?? '';
    final lastName = schemeData['lastName']?.toString().trim() ?? '';
    final mobile = schemeData['mobile']?.toString().trim() ?? '';
    final email = schemeData['email']?.toString().trim() ?? '';
    final address = schemeData['address']?.toString().trim() ?? '';
    final schemeName = schemeData['schemeName']?.toString().trim() ?? '';
    final schemeAmount = schemeData['schemeAmount']?.toString().trim() ?? '';
    final schemeDuration = schemeData['schemeDuration'] as int?;
    final paymentReference = schemeData['paymentReference'] as String?;
    final paymentResponse = schemeData['paymentResponse'] as Map<String, dynamic>?;
    
    // Combine firstName and lastName for the name field
    final name = '$firstName $lastName'.trim();
    
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    print('Adding new scheme for user: ${user.uid}');
    print('🔍 Full schemeData: $schemeData');
    print('🔍 schemeDuration type: ${schemeDuration.runtimeType}');
    print('🔍 schemeDuration value: $schemeDuration');
    print('🔍 paymentResponse: $paymentResponse');
    print('Scheme data: Name=$name, Mobile=$mobile, Email=$email, Scheme=$schemeName, Amount=$schemeAmount, Duration=$schemeDuration');
    
    // Get accurate timestamp
    final time = await getAccurateTime();
    
    // Create scheme document with dynamic progress based on duration
    final DocumentReference result = await FirebaseFirestore.instance.collection("savings").add({
      "userId": user.uid,
      "name": name,
      "mobile": mobile,
      "email": email,
      "address": address,
      "schemeName": schemeName,
      "installmentAmount": schemeAmount,
      "schemeDuration": schemeDuration, // Store the duration
      ...schemeData,
      "progress": generateProgress(duration: schemeDuration, paymentReference: paymentReference, paymentResponse: paymentResponse),
      "status": true,
      "createdAt": FieldValue.serverTimestamp()
    });
    
    print('✅ New scheme added successfully with ID: ${result.id}');
    print('📊 Progress created with ${schemeDuration ?? 12} months');
    if (paymentReference != null) {
      print('💰 Payment reference stored: $paymentReference');
    }
    if (paymentResponse != null) {
      print('📊 Complete payment response stored in first month');
    }
    
    return result.id; // Return the document ID for future reference
    
  } catch (e) {
    print('❌ Error adding new scheme: $e');
    return null; // Return null to indicate failure
  }
}