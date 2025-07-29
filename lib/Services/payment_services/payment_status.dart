import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/payment_status_screen.dart';
import 'package:hassanjewellers/Services/firebase_services/updateProgressItem.dart';
import 'package:hassanjewellers/Services/firebase_services/addNewScheme.dart';
import 'package:http/http.dart' as http;

Future<void> fetchPaymentStatus(String orderNo, String uid, String operation, Map<String, dynamic> schemeData, BuildContext context) async {
  print("Fetching payment status started...");
  
  bool hasNavigated = false; // Flag to prevent multiple navigations

  const String url =
      'https://spt.uvm.mybluehostin.me/api/payment/payment_status.php';

  print("Order No: $orderNo");
  print("Operation: $operation");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'order_no': orderNo}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      print('Response: $data'); // Debugging output

      // Check for reference number
      if (data.containsKey('reference_no')) {
        String referenceNo = data['reference_no'].toString();
        print("Reference Number: $referenceNo");

        // Check order status to ensure payment was successful
        if (data.containsKey('order_status')) {
          String orderStatus = data['order_status'];
          print("Order Status: $orderStatus");

          if (orderStatus == "Successful") {
            print("✅ Payment was successful!");
            print("🔄 About to navigate to success screen...");
            
            // Call appropriate function based on operation
            if (operation == 'add') {
              print("🆕 Adding new scheme...");
              print("🔍 Payment response data to be stored: $data");
              
              // Add payment reference and complete payment response to schemeData for new schemes
              schemeData['paymentReference'] = referenceNo;
              schemeData['paymentResponse'] = data; // Store complete payment response
              
              final schemeId = await addNewScheme(schemeData);
              if (schemeId != null) {
                print("✅ New scheme added successfully with ID: $schemeId");
                print("💰 Payment reference stored in first month: $referenceNo");
                print("📊 Complete payment response stored in first month");
              }
            } else if (operation == 'update') {
              print("📝 Updating existing scheme...");
              print("🔍 Payment response data to be stored: $data");
              updateProgressItem(uid, referenceNo, data).then((value) => {
                    print("print final"),
                    print(value),
                  });
            } else {
              print("⚠️ Unknown operation: $operation");
            }
            
            // Navigate to success screen
            print("🚀 Navigating to PaymentStatusScreen with success=true");
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentStatusScreen(
                    isSuccess: true,
                    message: "Your payment has been processed successfully.",
                    referenceNo: referenceNo,
                  ),
                ),
              );
              hasNavigated = true;
              print("✅ Navigation to success screen completed");
            } catch (e) {
              print("❌ Error during navigation: $e");
            }
          } else {
            print("❌ Payment was not successful.");
            print("🔄 About to navigate to failure screen...");
            
            // Navigate to failure screen
            try {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => PaymentStatusScreen(
                    isSuccess: false,
                    message: "Payment failed. Please try again.",
                  ),
                ),
              );
              hasNavigated = true;
              print("✅ Navigation to failure screen completed");
            } catch (e) {
              print("❌ Error during navigation: $e");
            }
          }
        } else {
          print("⚠️ 'order_status' not found in response.");
          
          // Navigate to failure screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => PaymentStatusScreen(
                isSuccess: false,
                message: "Unable to verify payment status. Please try again.",
              ),
            ),
          );
          hasNavigated = true;
        }
      } else {
        print("⚠️ 'reference_no' not found in response.");
        
        // Navigate to failure screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentStatusScreen(
              isSuccess: false,
              message: "Payment verification failed. Please try again.",
            ),
          ),
        );
        hasNavigated = true;
      }

      // Check for status number
      if (data.containsKey('status')) {
        String status = data['status'];
        print("status : $status");
      } else {
        print("⚠️ 'status' not found in response.");
      }

      // Check for errorCode number
      if (data.containsKey('error_code')) {
        String errorCode = data['error_code'];
        print("error_code Number: ${errorCode.toString()}");
      } else {
        print("⚠️ 'error_code' not found in response.");
      }
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
      
      // Navigate to failure screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentStatusScreen(
            isSuccess: false,
            message: "Network error. Please check your connection and try again.",
          ),
        ),
      );
      hasNavigated = true;
    }
  } catch (e) {
    print('⚠️ Exception: $e');
    
    // Only navigate if no navigation has already occurred
    if (!hasNavigated) {
      print("🔄 Navigating to failure screen due to exception");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentStatusScreen(
            isSuccess: false,
            message: "An error occurred. Please try again.",
          ),
        ),
      );
    } else {
      print("⚠️ Skipping navigation due to exception - already navigated");
    }
  }
}
