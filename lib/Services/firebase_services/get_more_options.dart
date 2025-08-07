import 'package:cloud_firestore/cloud_firestore.dart';

Future<Map<String, dynamic>?> getMoreOptions() async {
  try {
    print('Fetching moreOptions from Firebase...');
    // Get moreOptions document from info collection
    final docSnapshot = await FirebaseFirestore.instance
        .collection('info')
        .doc('moreOptions')
        .get(const GetOptions(source: Source.server));
    
    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      print('MoreOptions data fetched: $data');
      return data;
    } else {
      print('MoreOptions document does not exist');
      return null;
    }
    
  } catch (e) {
    print('Error fetching more options: $e');
    return null;
  }
} 