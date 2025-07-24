import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';

Future<bool> deleteUserAddress(String addressId) async {
  try {
    // Get current user
    final user = getCurrentUser();
    if (user == null) return false;
    
    // Query to find user document by UID
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    
    if (querySnapshot.docs.isEmpty) {
      return false;
    }
    
    // Get user document reference
    final userDoc = querySnapshot.docs.first.reference;
    
    // Get current user data
    final userData = querySnapshot.docs.first.data();
    final addresses = List<Map<String, dynamic>>.from(userData['addresses'] ?? []);
    
    // Remove the address with the specified ID
    final initialCount = addresses.length;
    addresses.removeWhere((address) => address['id'] == addressId);
    final finalCount = addresses.length;
    
    print('Delete operation: $initialCount -> $finalCount addresses'); // Debug print
    
    // Update the user document with the modified addresses array
    await userDoc.update({
      'addresses': addresses,
    });
    
    print('Firebase update completed'); // Debug print
    return true;
  } catch (e) {
    print('Error deleting address: $e');
    return false;
  }
} 