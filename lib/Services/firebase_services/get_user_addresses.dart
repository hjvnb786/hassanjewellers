import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';

Future<List<Map<String, dynamic>>> getUserAddresses() async {
  try {
    // Get current user
    final user = getCurrentUser();
    if (user == null) return [];
    
    // Query to find user document by UID with cache control
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get(const GetOptions(source: Source.server));
    
    if (querySnapshot.docs.isEmpty) {
      return [];
    }
    
    // Get user document
    final userDoc = querySnapshot.docs.first.data();
    
    // Extract addresses array
    final addresses = userDoc['addresses'] as List<dynamic>?;
    
    if (addresses == null || addresses.isEmpty) {
      return [];
    }
    
    // Convert to List<Map<String, dynamic>>
    return addresses.map((address) => Map<String, dynamic>.from(address)).toList();
    
  } catch (e) {
    print('Error fetching user addresses: $e');
    return [];
  }
} 