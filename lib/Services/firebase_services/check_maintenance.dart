import 'package:cloud_firestore/cloud_firestore.dart';

class MaintenanceService {
  static Future<bool> isMaintenanceMode() async {
    try {
      // Get maintenance status from Firestore
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        print('⚠️ Operations document not found, allowing app to continue');
        return false;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      bool maintenanceWindow = data['maintenanceWindow'] ?? false;
      
      print('🔧 Maintenance window status: $maintenanceWindow');
      
      return maintenanceWindow;
    } catch (e) {
      print('❌ Error checking maintenance status: $e');
      // In case of error, allow app to continue
      return false;
    }
  }

  static Future<String?> getMaintenanceMessage() async {
    try {
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        return null;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      return data['maintenanceMessage'] as String?;
    } catch (e) {
      print('❌ Error getting maintenance message: $e');
      return null;
    }
  }

  static Future<String?> getEstimatedDuration() async {
    try {
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        return null;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      return data['maintenanceDuration'] as String?;
    } catch (e) {
      print('❌ Error getting maintenance duration: $e');
      return null;
    }
  }
}
