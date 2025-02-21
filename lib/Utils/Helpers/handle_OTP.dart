import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

Future<String> handleOTP(
    {required String mobileNumber,
    String? otp,
    String? uid,
    BuildContext? context}) async {
  print(
      'Function called with mobileNumber: $mobileNumber, otp: $otp, uid: $uid');

  final url = Uri.parse('https://spt.uvm.mybluehostin.me/api/auth/sendOTP.php');
  print('URL parsed: $url');

  // Determine the action and construct the request body
  String action = otp != null ? 'verifyOTP' : 'sendOTP';
  print('Action determined: $action');

  Map<String, dynamic> body = {
    'action': action,
    'mobileNumber': mobileNumber,
  };
  print('Initial body: $body');

  if (otp != null) {
    body['otp'] = otp;
    print('OTP added to body: $otp');
  }
  if (uid != null) {
    body['uid'] = uid;
    print('UID added to body: $uid');
  }

  // Encode the body to JSON
  String bodyJson = jsonEncode(body);
  print('JSON-encoded body: $bodyJson');

  try {
    // Retrieve stored cookies
    final prefs = await SharedPreferences.getInstance();
    print('SharedPreferences instance retrieved');

    String? cookies = prefs.getString('cookies');
    print('Cookies retrieved from SharedPreferences: $cookies');

    // Make the POST request with headers
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (cookies != null) 'Cookie': cookies,
      },
      body: bodyJson,
    );

    print('POST request sent. Status code: ${response.statusCode}');

    // Check the response status
    if (response.statusCode == 200) {
      // Parse the response
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');

      print('Success: ${responseData['message']}');

      // Check if the response contains the Firebase custom token
      if (responseData.containsKey('firebaseToken')) {
        String token = responseData['firebaseToken'];
        print("Received Firebase token: $token");

        // Sign in to Firebase with the custom token
        try {
          UserCredential userCredential =
              await FirebaseAuth.instance.signInWithCustomToken(token);
          print("Firebase sign-in successful: ${userCredential.user?.uid}");

          return "SUCCESS";
        } on FirebaseAuthException catch (e) {
          print("Firebase sign-in failed: ${e.message}");
        }
      }

      // Extract and store cookies from response headers
      if (response.headers['set-cookie'] != null) {
        await prefs.setString('cookies', response.headers['set-cookie']!);
        print(
            'Cookies stored in SharedPreferences: ${response.headers['set-cookie']}');
      }

      return "SUCCESS";
    } else {
      print('Failed: ${response.statusCode} - ${response.body}');
      return "FAILURE";
    }
  } catch (e) {
    print('Error occurred: $e');
    return "FAILURE";
  }
}
