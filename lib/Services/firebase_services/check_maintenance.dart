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


}
