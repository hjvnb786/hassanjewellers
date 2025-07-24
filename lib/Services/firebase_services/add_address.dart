import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';

Future<String?> addAddressToUser(Map<String, dynamic> addressData) async {
  try {
    // Get current user
    final user = getCurrentUser();
    if (user == null) return null;
    
    // Prepare address data with unique ID
    final addressWithMetadata = {
      ...addressData,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
    };
    
    // Query to find user document by UID (not document ID)
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    
    if (querySnapshot.docs.isNotEmpty) {
      // User exists - update the document
      final userDoc = querySnapshot.docs.first.reference;
      await userDoc.update({
        'addresses': FieldValue.arrayUnion([addressWithMetadata]),
      });
    } else {
      // User doesn't exist - create new document
      await FirebaseFirestore.instance.collection('users').add({
        'uid': user.uid,
        'addresses': [addressWithMetadata],
      });
    }
    
    return addressWithMetadata['id'];
  } catch (e) {
    print('Error adding address: $e');
    return null;
  }
} 