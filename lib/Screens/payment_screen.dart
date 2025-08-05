import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Services/firebase_services/generateOrderId.dart';
import 'package:hassanjewellers/Services/payment_services/payment_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Function to retrieve order ID from Firestore for existing schemes
  Future<String> _getOrderIdFromFirestore() async {
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Check if we have a scheme ID (document ID) for direct lookup
      final schemeId = widget.formData?['schemeId'];
      
      if (schemeId != null && schemeId.isNotEmpty) {
        print("🔍 Using scheme ID for direct lookup: $schemeId");
        
        // Direct lookup using document ID
        final document = await FirebaseFirestore.instance
            .collection('savings')
            .doc(schemeId)
            .get();

        if (!document.exists) {
          throw Exception('Scheme document not found with ID: $schemeId');
        }

        final orderId = document.data()?['orderId'] as String?;
        if (orderId == null || orderId.isEmpty) {
          throw Exception('Order ID not found in scheme document');
        }

        print("✅ Retrieved order ID from Firestore using document ID: $orderId");
        return orderId;
      }

      // Fallback to name-based search if no document ID
      print("🔍 No scheme ID provided, falling back to name-based search");
      print("🔍 Scheme name to search: ${widget.formData?['schemeName'] ?? widget.name}");

      // Get all schemes for the user to debug
      final allSchemes = await FirebaseFirestore.instance
          .collection('savings')
          .where('userId', isEqualTo: user.uid)
          .get();

      print("📊 Found ${allSchemes.docs.length} schemes for user");

      // Log all scheme names for debugging
      for (var doc in allSchemes.docs) {
        final data = doc.data();
        final schemeName = data['schemeDetails']?['schemeName'] ?? 'Unknown';
        final orderId = data['orderId'] ?? 'No Order ID';
        print("📋 Scheme: $schemeName, Order ID: $orderId, Doc ID: ${doc.id}");
      }

      // Try exact match first
      var querySnapshot = await FirebaseFirestore.instance
          .collection('savings')
          .where('userId', isEqualTo: user.uid)
          .where('schemeDetails.schemeName', isEqualTo: widget.formData?['schemeName'] ?? widget.name)
          .limit(1)
          .get();

      // If no exact match, try partial match
      if (querySnapshot.docs.isEmpty) {
        print("⚠️ No exact match found, trying partial match...");
        
        // Find the first scheme that contains the scheme name
        for (var doc in allSchemes.docs) {
          final data = doc.data();
          final schemeName = data['schemeDetails']?['schemeName'] ?? '';
          final searchName = widget.formData?['schemeName'] ?? widget.name ?? '';
          
          if (schemeName.contains(searchName) || searchName.contains(schemeName)) {
            final orderId = data['orderId'] as String?;
            if (orderId != null && orderId.isNotEmpty) {
              print("✅ Found partial match - Scheme: $schemeName, Order ID: $orderId");
              return orderId;
            }
          }
        }
        
        throw Exception('No matching scheme found in Firestore');
      }

      final document = querySnapshot.docs.first;
      final orderId = document.data()['orderId'] as String?;

      if (orderId == null || orderId.isEmpty) {
        throw Exception('Order ID not found in scheme document');
      }

      print("✅ Retrieved order ID from Firestore: $orderId");
      return orderId;
    } catch (e) {
      print("❌ Error retrieving order ID from Firestore: $e");
      // Fallback to a simple order ID
      return "ORD-${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  Future<void> _initializePayment() async {
    try {
      // Use formData if available, otherwise use the old parameters
      if (widget.formData != null) {
        // Extract data from formData for payment
        final schemeAmount = widget.formData!['schemeAmount'] ?? '₹5,000';
        final firstName = widget.formData!['firstName'] ?? '';
        final lastName = widget.formData!['lastName'] ?? '';
        final fullName = '$firstName $lastName'.trim();
        
        // Clean the amount for Firebase order ID generation
        String cleanAmount = schemeAmount.replaceAll('₹', '').replaceAll(',', '');
        
        // Determine order ID based on operation
        if (widget.operation == 'add') {
          // For new schemes, generate a new order ID
          await createOrderIdDocumentIfNotExists();
          orderId = await generateOrderId(cleanAmount);
        } else {
          // For existing schemes, retrieve the order ID from Firestore
          orderId = await _getOrderIdFromFirestore();
        }
        
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
        
        // Determine order ID based on operation
        if (widget.operation == 'add') {
          // For new schemes, generate a new order ID
          await createOrderIdDocumentIfNotExists();
          orderId = await generateOrderId(cleanAmount);
        } else {
          // For existing schemes, retrieve the order ID from Firestore
          orderId = await _getOrderIdFromFirestore();
        }
        
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
