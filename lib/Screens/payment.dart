import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Payment extends StatelessWidget {
  const Payment({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        title: const Text('Hassan Jewellers'),
      ),
      body: const WebView(
        initialUrl: 'https://pmny.in/4rCT8CVMTWIb', // Replace with your URL
        javascriptMode: JavascriptMode.unrestricted,
        backgroundColor: Colors.white,
      ),
    );
  }
}
