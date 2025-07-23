import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateOrderId(String uid) {

  print("uid for order gen: $uid");

  // Get current timestamp for uniqueness
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

  // Generate a hash from the UID (optional but keeps it consistent in length)
  String hash = md5.convert(utf8.encode(uid)).toString().substring(0, 8);

  // Construct order ID
  return "ORD-${hash.toUpperCase()}-$timestamp";
}
