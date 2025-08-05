import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Services/firebase_services/generateOrderId.dart';
import 'package:hassanjewellers/Services/payment_services/payment_status.dart';

import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';

class PaymentScreen extends StatefulWidget {
  final String? id;
  final String? amount;
  final String? name;
  final Map<String, dynamic>? formData;
  final String operation;

  const PaymentScreen({
    super.key, 
    this.id, 
    this.amount, 
    this.name,
    this.formData,
    required this.operation,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController webViewController;
  LoadRequestMethod postMethod = LoadRequestMethod.post;

  int loadingValue = 0;
  bool cancelState = false;
  bool isLoading = true;

  String orderId = "";

  @override
  void initState() {
    super.initState();
    _initializePayment();
  }

  Future<void> _initializePayment() async {
    try {
      // Ensure the order ID document exists in Firestore
      await createOrderIdDocumentIfNotExists();
      
      // Use formData if available, otherwise use the old parameters
      if (widget.formData != null) {
        // Extract data from formData for payment
        final schemeAmount = widget.formData!['schemeAmount'] ?? '₹5,000';
        final firstName = widget.formData!['firstName'] ?? '';
        final lastName = widget.formData!['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        // Clean the amount for Firebase order ID generation
        String cleanAmount = schemeAmount.replaceAll('₹', '').replaceAll(',', '');
        
        // Generate order ID using Firebase
        orderId = await generateOrderId(cleanAmount);
        
        // Prepare the JSON data as a Map
        Map<String, dynamic> payload = {
          "name": fullName.isNotEmpty ? fullName : 'Scheme User',
          "amount": cleanAmount,
          "order_no": orderId
        };
        
        // Convert the Map to a JSON string
        String jsonString = jsonEncode(payload);
        
        print("jsonString: $jsonString");
        
        _setupWebViewController(jsonString, true);
      } else {
        // Use old parameters for backward compatibility
        String cleanAmount = (widget.amount ?? '5000').substring(0, (widget.amount ?? '5000').length - 2);
        
        // Generate order ID using Firebase
        orderId = await generateOrderId(cleanAmount);
        
        // Prepare the JSON data as a Map
        Map<String, dynamic> payload = {
          "name": widget.name ?? 'Default User',
          "amount": cleanAmount,
          "order_no": orderId
        };
        
        // Convert the Map to a JSON string
        String jsonString = jsonEncode(payload);
        
        print("jsonString: $jsonString");
        
        _setupWebViewController(jsonString, false);
      }
    } catch (e) {
      print("❌ Error generating order ID: $e");
      // Fallback to a simple order ID if Firebase fails
      orderId = "ORD-${DateTime.now().millisecondsSinceEpoch}";
      
      // Setup web controller with fallback order ID
      if (widget.formData != null) {
        final schemeAmount = widget.formData!['schemeAmount'] ?? '₹5,000';
        final firstName = widget.formData!['firstName'] ?? '';
        final lastName = widget.formData!['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        String cleanAmount = schemeAmount.replaceAll('₹', '').replaceAll(',', '');
        
        Map<String, dynamic> payload = {
          "name": fullName.isNotEmpty ? fullName : 'Scheme User',
          "amount": cleanAmount,
          "order_no": orderId
        };
        
        String jsonString = jsonEncode(payload);
        _setupWebViewController(jsonString, true);
      } else {
        String cleanAmount = (widget.amount ?? '5000').substring(0, (widget.amount ?? '5000').length - 2);
        
        Map<String, dynamic> payload = {
          "name": widget.name ?? 'Default User',
          "amount": cleanAmount,
          "order_no": orderId
        };
        
        String jsonString = jsonEncode(payload);
        _setupWebViewController(jsonString, false);
      }
    }
  }

  void _setupWebViewController(String jsonString, bool isFormData) {
    webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int value) {
            setState(() {
              loadingValue = value;
            });
          },
          onUrlChange: (UrlChange request) {
            if (kDebugMode) {
              print(request.url);
            }

            if (request.url ==
                'https://spt.uvm.mybluehostin.me/api/payment/success.html') {
              print("success success success");

              final schemeData = widget.formData ?? {};
              
              if (isFormData) {
                fetchPaymentStatus(orderId, 'scheme_${DateTime.now().millisecondsSinceEpoch}', widget.operation, schemeData, context);
              } else {
                fetchPaymentStatus(orderId, widget.id ?? 'default', widget.operation, schemeData, context);
              }
            }

            if (request.url ==
                'https://spt.uvm.mybluehostin.me/api/payment/close_browser.html') {
              Navigator.of(context).pop();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse("https://spt.uvm.mybluehostin.me/api/payment/"),
          method: postMethod,
          headers: {
            'Content-Type': 'application/json',
          },
          body: Uint8List.fromList(jsonString.codeUnits));
    
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Payment'),
        ),
        body: PopScope(
          canPop: cancelState,
          onPopInvokedWithResult: (bool didPop, String? result) {
            if (!didPop) {
              print("cant leave without me");
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Warning"),
                      content:
                          const Text("All your payment progress will be lost"),
                      actions: <Widget>[
                        TextButton(
                          child: const Text("No, Don't Cancel"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: const Text("Yes, Cancel"),
                          onPressed: () {
                            setState(() {
                              cancelState = true;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MyApp()),
                                (Route<dynamic> route) => false,
                              );
                            });
                          },
                        ),
                      ],
                    );
                  });
            }
          },
          child: Column(
            children: [
              if (loadingValue < 100) const LinearProgressIndicator(),
              if (isLoading)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Initializing payment...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: WebViewWidget(controller: webViewController),
                ),
            ],
          ),
        ));
  }
}
