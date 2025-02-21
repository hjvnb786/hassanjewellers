import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../main.dart';

class Payment extends StatefulWidget {
  const Payment({super.key, required this.id});

  final String id;

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  late final WebViewController webViewController;
  LoadRequestMethod postMethod = LoadRequestMethod.post;
  String jsonPayload = '{"age": "John Doe"}';
  int loadingValue = 0;
  bool cancelState = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

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
              updateProgressItem(widget.id).then((value) => {
                    print(value),
                    Navigator.of(context).pop(),
                    Navigator.of(context).pop()
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
          body: Uint8List.fromList(jsonPayload.codeUnits));
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
