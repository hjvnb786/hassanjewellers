import 'package:cloud_firestore/cloud_firestore.dart';

Future<QueryDocumentSnapshot<Map<String, dynamic>>?> getDocumentByUid(
    String? uid, String collectionName) async {
  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection(collectionName)
        .where("uid", isEqualTo: uid)
        .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    return querySnapshot.docs.first;
  } catch (e) {
    return null;
  }
} 