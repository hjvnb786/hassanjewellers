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
    
    // Combine firstName and lastName for the name field
    final name = '$firstName $lastName'.trim();
    
    // Get current user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    
    print('Adding new scheme for user: ${user.uid}');
    print('Scheme data: Name=$name, Mobile=$mobile, Email=$email, Scheme=$schemeName, Amount=$schemeAmount');
    
    // Get accurate timestamp
    final time = await getAccurateTime();
    
    // Create scheme document
    final DocumentReference result = await FirebaseFirestore.instance.collection("savings").add({
      "userId": user.uid,
      "name": name,
      "mobile": mobile,
      "email": email,
      "address": address,
      "schemeName": schemeName,
      "installmentAmount": schemeAmount,
      ...schemeData,
      "progress": generateProgress(),
      "status": true,
      "createdAt": FieldValue.serverTimestamp()
    });
    
    print('✅ New scheme added successfully with ID: ${result.id}');
    
    return result.id; // Return the document ID for future reference
    
  } catch (e) {
    print('❌ Error adding new scheme: $e');
    return null; // Return null to indicate failure
  }
}