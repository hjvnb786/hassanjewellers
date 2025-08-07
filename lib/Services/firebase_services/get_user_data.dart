import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';

Future<Map<String, dynamic>?> getUserData() async {
  try {
    // Get current user
    final user = getCurrentUser();
    if (user == null) return null;
    
    // Query to find user document by UID with cache control
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get(const GetOptions(source: Source.server));
    
    if (querySnapshot.docs.isEmpty) {
      return null;
    }
    
    // Return entire user document
    return querySnapshot.docs.first.data();
    
  } catch (e) {
    print('Error fetching user data: $e');
    return null;
  }
} 