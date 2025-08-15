import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ForceUpdateService {
  static Future<bool> isForceUpdateRequired() async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;
      
      print('📱 Current app version: $currentVersion');
      
      // Get force update version from Firestore
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        print('⚠️ Operations document not found, allowing app to continue');
        return false;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      String? forceUpdateVersion = data['forceUpdateVersion'] as String?;
      
      if (forceUpdateVersion == null || forceUpdateVersion.isEmpty) {
        print('ℹ️ No force update version set, allowing app to continue');
        return false;
      }
      
      print('🔍 Force update version from server: $forceUpdateVersion');
      
      // Compare versions
      bool updateRequired = _compareVersions(currentVersion, forceUpdateVersion);
      
      print('📊 Force update required: $updateRequired');
      return updateRequired;
      
    } catch (e) {
      print('❌ Error checking force update: $e');
      // In case of error, allow app to continue
      return false;
    }
  }
  
  // Debug method to test force update functionality
  static Future<bool> isForceUpdateRequiredDebug({String? testVersion}) async {
    try {
      // Get current app version
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = testVersion ?? packageInfo.version;
      
      print('📱 Current app version (debug): $currentVersion');
      
      // Get force update version from Firestore
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        print('⚠️ Operations document not found, allowing app to continue');
        return false;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      String? forceUpdateVersion = data['forceUpdateVersion'] as String?;
      
      if (forceUpdateVersion == null || forceUpdateVersion.isEmpty) {
        print('ℹ️ No force update version set, allowing app to continue');
        return false;
      }
      
      print('🔍 Force update version from server: $forceUpdateVersion');
      
      // Compare versions
      bool updateRequired = _compareVersions(currentVersion, forceUpdateVersion);
      
      print('📊 Force update required (debug): $updateRequired');
      return updateRequired;
      
    } catch (e) {
      print('❌ Error checking force update (debug): $e');
      // In case of error, allow app to continue
      return false;
    }
  }
  
  static bool _compareVersions(String currentVersion, String requiredVersion) {
    try {
      // Remove build numbers (everything after +) for comparison
      String cleanCurrent = currentVersion.split('+')[0];
      String cleanRequired = requiredVersion.split('+')[0];
      
      print('🔍 Comparing versions: $cleanCurrent vs $cleanRequired');
      
      List<int> current = cleanCurrent.split('.').map((e) => int.parse(e)).toList();
      List<int> required = cleanRequired.split('.').map((e) => int.parse(e)).toList();
      
      // Pad with zeros if needed
      while (current.length < 3) current.add(0);
      while (required.length < 3) required.add(0);
      
      // Compare major version
      if (current[0] < required[0]) return true;
      if (current[0] > required[0]) return false;
      
      // Compare minor version
      if (current[1] < required[1]) return true;
      if (current[1] > required[1]) return false;
      
      // Compare patch version
      if (current[2] < required[2]) return true;
      
      return false;
    } catch (e) {
      print('❌ Error comparing versions: $e');
      return false;
    }
  }
  
  static Future<String?> getForceUpdateVersion() async {
    try {
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        return null;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      return data['forceUpdateVersion'] as String?;
    } catch (e) {
      print('❌ Error getting force update version: $e');
      return null;
    }
  }
  
  static Future<String?> getPlayStoreUrl() async {
    try {
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        return null;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      return data['playStoreUrl'] as String?;
    } catch (e) {
      print('❌ Error getting Play Store URL: $e');
      return null;
    }
  }
  
  static Future<String?> getAppStoreUrl() async {
    try {
      DocumentSnapshot operationsDoc = await FirebaseFirestore.instance
          .collection('info')
          .doc('operations')
          .get();
      
      if (!operationsDoc.exists) {
        return null;
      }
      
      Map<String, dynamic> data = operationsDoc.data() as Map<String, dynamic>;
      return data['appStoreUrl'] as String?;
    } catch (e) {
      print('❌ Error getting App Store URL: $e');
      return null;
    }
  }
}
