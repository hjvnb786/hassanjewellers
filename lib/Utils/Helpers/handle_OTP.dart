import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

Future<Map<String, dynamic>> handleOTP(
    {required String mobileNumber,
    String? otp,
    String? uid,
    BuildContext? context}) async {
  print('Function called with mobileNumber: $mobileNumber, otp: $otp, uid: $uid');

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

    // Make the POST request with headers and timeout
    print('Starting API request...');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        if (cookies != null) 'Cookie': cookies,
      },
      body: bodyJson,
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        print('API request timed out after 15 seconds');
        throw TimeoutException('API request took too long');
      },
    );

    print('POST request sent. Status code: ${response.statusCode}');

    // Check the response status
    if (response.statusCode == 200) {
      // Parse the response
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');

      // First check if the response indicates success
      if (responseData['success'] == false) {
        print('API returned error: ${responseData['error']}');
        return {
          'status': 'FAILURE',
          'error': responseData['error'],
        };
      }

      print('Success: ${responseData['message']}');

      // Extract and store cookies from response headers
      if (response.headers['set-cookie'] != null) {
        await prefs.setString('cookies', response.headers['set-cookie']!);
        print('Cookies stored in SharedPreferences: ${response.headers['set-cookie']}');
      }

      // Check if the response contains the Firebase custom token
      if (responseData.containsKey('firebaseToken')) {
        String token = responseData['firebaseToken'];
        print("Received Firebase token: $token");
        return {
          'status': 'SUCCESS',
          'token': token,
        };
      }

      // If we get here without a firebaseToken, it means we're just sending OTP
      return {
        'status': 'SUCCESS',
        'message': responseData['message'],
      };
    } else {
      print('Failed: ${response.statusCode} - ${response.body}');
      return {
        'status': 'FAILURE',
        'error': 'Server error: ${response.statusCode}',
      };
    }
  } on TimeoutException catch (e) {
    print('Timeout error: $e');
    return {
      'status': 'FAILURE',
      'error': 'Request timed out',
    };
  } catch (e) {
    print('Error occurred: $e');
    return {
      'status': 'FAILURE',
      'error': e.toString(),
    };
  }
}

