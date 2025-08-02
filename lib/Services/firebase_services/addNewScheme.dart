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
    
    // Create scheme document with three nested objects
    final DocumentReference result = await FirebaseFirestore.instance.collection("savings").add({
      "userId": user.uid,
      "status": true,
      "createdAt": FieldValue.serverTimestamp(),
      
      "personalDetails": {
        "firstName": firstName,
        "lastName": lastName,
        "mobile": mobile,
        "email": email,
        "deliveryAddress": schemeData['deliveryAddress']?.toString().trim() ?? address,
        "additionalDetails": _extractAdditionalDetails(schemeData),
      },
      
      "schemeDetails": {
        "schemeName": schemeName,
        "schemeDescription": schemeData['schemeDescription']?.toString().trim() ?? '',
        "installmentAmount": schemeAmount,
        "schemeDuration": schemeDuration,
      },
      
      "schemeProgress": {
        "installments": generateProgress(duration: schemeDuration, paymentReference: paymentReference, paymentResponse: paymentResponse),
      },
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

Map<String, dynamic> _extractAdditionalDetails(Map<String, dynamic> schemeData) {
  // Define basic personal fields that are handled separately
  final basicPersonalFields = [
    'firstName', 'lastName', 'mobile', 'email', 'address', 'deliveryAddress'
  ];
  
  final standardSchemeFields = [
    'schemeName', 'schemeDescription', 'schemeAmount', 'schemeDuration'
  ];
  
  final paymentFields = ['paymentReference', 'paymentResponse'];
  
  // Extract additional details (any field not in basic personal or scheme lists)
  Map<String, dynamic> additionalDetails = {};
  
  print('🔍 Extracting additional details from schemeData: $schemeData');
  print('🔍 Basic personal fields to exclude: $basicPersonalFields');
  print('🔍 Standard scheme fields to exclude: $standardSchemeFields');
  print('🔍 Payment fields to exclude: $paymentFields');
  
  schemeData.forEach((key, value) {
    print('🔍 Checking field: $key = $value');
    
    // Skip fields that end with '_label' as they are UI labels
    if (key.toString().endsWith('_label')) {
      print('❌ Excluded label field: $key = $value');
      return; // Skip this field
    }
    
    if (!basicPersonalFields.contains(key) && 
        !standardSchemeFields.contains(key) &&
        !paymentFields.contains(key) &&
        value != null && 
        value.toString().isNotEmpty) {
      additionalDetails[key] = value.toString().trim();
      print('✅ Added to additionalDetails: $key = $value');
    } else {
      print('❌ Excluded from additionalDetails: $key = $value');
    }
  });
  
  print('🔍 Final additionalDetails: $additionalDetails');
  return additionalDetails;
}