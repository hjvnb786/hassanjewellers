import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';

Future<String?> updateUserAddress(String addressId, Map<String, dynamic> addressData) async {
  try {
    // Get current user
    final user = getCurrentUser();
    if (user == null) return null;
    
    // Query to find user document by UID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    
    // Get user document reference
    final userDoc = querySnapshot.docs.first.reference;
    
    // Get current user data
    final userData = querySnapshot.docs.first.data();
    final addresses = List<Map<String, dynamic>>.from(userData['addresses'] ?? []);
    
    // Find and update the specific address
    bool addressFound = false;
    for (int i = 0; i < addresses.length; i++) {
      if (addresses[i]['id'] == addressId) {
        // Update the address with new data while preserving the ID
        addresses[i] = {
          ...addressData,
          'id': addressId, // Preserve the original ID
        };
        addressFound = true;
        break;
      }
    }
    
    if (!addressFound) {
      print('Address with ID $addressId not found');
      return null;
    }
    
    // Update the user document with the modified addresses array
    await userDoc.update({
      'addresses': addresses,
    });
    
    return addressId;
  } catch (e) {
    print('Error updating address: $e');
    return null;
  }
} 