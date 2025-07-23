import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/gen_order_id.dart';
import 'package:hassanjewellers/Services/payment_services/payment_status.dart';

import 'package:webview_flutter/webview_flutter.dart';
import '../main.dart';

class Payment extends StatefulWidget {
  final String id;
  final String amount;
  final String name;

  const Payment(
      {super.key, required this.id, required this.amount, required this.name});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late final WebViewController webViewController;
  LoadRequestMethod postMethod = LoadRequestMethod.post;

  int loadingValue = 0;
  bool cancelState = false;

  String orderId = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    orderId = generateOrderId(widget.id);

    // Prepare the JSON data as a Map
    Map<String, dynamic> payload = {
      "name": widget.name,
      "amount": widget.amount.substring(0, widget.amount.length - 2),
      "order_no": orderId
    };

    // Convert the Map to a JSON string
    String jsonString = jsonEncode(payload);

    print("jsonString: $jsonString");

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

              fetchPaymentStatus(orderId, widget.id).then((value) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              });
            }

            if (request.url ==
                'https://spt.uvm.mybluehostin.me/api/payment/close_browser.html') {
              Navigator.of(context).pop();
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

          //body: Uint8List.fromList(jsonPayload.codeUnits));
          body: Uint8List.fromList(jsonString.codeUnits));
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
              Expanded(
                child: WebViewWidget(controller: webViewController),
              ),
            ],
          ),
        ));
  }
}
