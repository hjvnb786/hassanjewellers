import 'dart:convert';
import 'package:hassanjewellers/Utils/Services/firebase_services/updateProgressItem.dart';
import 'package:http/http.dart' as http;

Future<void> fetchPaymentStatus(String orderNo, String uid) async {
  print("Fetching payment status started...");

  const String url =
      'https://spt.uvm.mybluehostin.me/api/payment/payment_status.php';

  print("Order No: $orderNo");

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

        //update your firebase record
        updateProgressItem(uid, referenceNo).then((value) => {
              print("print final"),
              print(value),
            });
      } else {
        print("⚠️ 'reference_no' not found in response.");
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

      // Check for order status
      if (data.containsKey('order_status')) {
        String orderStatus = data['order_status'];
        print("Order Status: $orderStatus");

        if (orderStatus == "Successful") {
          print("✅ Payment was successful!");
        } else {
          print("❌ Payment was not successful.");
        }
      } else {
        print("⚠️ 'order_status' not found in response.");
      }
    } else {
      print('❌ Error: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('⚠️ Exception: $e');
  }
}
