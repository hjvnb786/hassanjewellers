import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Migration function to move additionalDetails from inside personalDetails to top level
/// This should be run once to update existing documents in the savings collection
Future<void> migrateAdditionalDetails() async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('❌ User not authenticated');
      return;
    }

    print('🔄 Starting migration of additionalDetails for user: ${user.uid}');

    // Get all savings documents for the current user
    final querySnapshot = await FirebaseFirestore.instance
        .collection('savings')
        .where('userId', isEqualTo: user.uid)
        .get();

    print('📊 Found ${querySnapshot.docs.length} documents to migrate');

    int migratedCount = 0;
    int skippedCount = 0;

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final personalDetails = data['personalDetails'] as Map<String, dynamic>?;
      
      // Check if additionalDetails exists inside personalDetails
      if (personalDetails != null && personalDetails.containsKey('additionalDetails')) {
        final additionalDetails = personalDetails['additionalDetails'];
        
        // Remove additionalDetails from personalDetails
        personalDetails.remove('additionalDetails');
        
        // Update the document with the new structure
        await FirebaseFirestore.instance
            .collection('savings')
            .doc(doc.id)
            .update({
          'personalDetails': personalDetails,
          'additionalDetails': additionalDetails,
        });
        
        print('✅ Migrated document: ${doc.id}');
        migratedCount++;
      } else {
        print('⏭️ Skipped document: ${doc.id} (no additionalDetails found)');
        skippedCount++;
      }
    }

    print('🎉 Migration completed!');
    print('✅ Migrated: $migratedCount documents');
    print('⏭️ Skipped: $skippedCount documents');
    
  } catch (e) {
    print('❌ Error during migration: $e');
  }
}

/// Function to check if migration is needed for a specific document
Future<bool> needsMigration(String documentId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('savings')
        .doc(documentId)
        .get();
    
    if (!doc.exists) {
      return false;
    }
    
    final data = doc.data();
    final personalDetails = data?['personalDetails'] as Map<String, dynamic>?;
    
    // Check if additionalDetails exists inside personalDetails
    return personalDetails != null && personalDetails.containsKey('additionalDetails');
  } catch (e) {
    print('❌ Error checking migration status: $e');
    return false;
  }
}

/// Function to migrate a single document
Future<bool> migrateSingleDocument(String documentId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('savings')
        .doc(documentId)
        .get();
    
    if (!doc.exists) {
      print('❌ Document not found: $documentId');
      return false;
    }
    
    final data = doc.data();
    final personalDetails = data?['personalDetails'] as Map<String, dynamic>?;
    
    if (personalDetails == null || !personalDetails.containsKey('additionalDetails')) {
      print('⏭️ Document does not need migration: $documentId');
      return false;
    }
    
    final additionalDetails = personalDetails['additionalDetails'];
    
    // Remove additionalDetails from personalDetails
    personalDetails.remove('additionalDetails');
    
    // Update the document with the new structure
    await FirebaseFirestore.instance
        .collection('savings')
        .doc(documentId)
        .update({
      'personalDetails': personalDetails,
      'additionalDetails': additionalDetails,
    });
    
    print('✅ Successfully migrated document: $documentId');
    return true;
    
  } catch (e) {
    print('❌ Error migrating document $documentId: $e');
    return false;
  }
}
