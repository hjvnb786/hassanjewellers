import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Screens/home.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String verifyId = "";
  TextEditingController otpController = TextEditingController();

  @override
  void initState() {
    generateOTP(widget.phoneNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: otpController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter 6 digit otp send to your phone number',
                ),
              ),
              TextButton(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue),
                ),
                onPressed: () {
                  verifyOTP();
                },
                child: const Text('Sumbit'),
              )
            ],
          ),
        ),
      ),
    );
  }

  void generateOTP(String phone) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) {},
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          verifyId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verifyId, smsCode: otpController.text.toString());

    await FirebaseAuth.instance.signInWithCredential(credential);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      );
    }
  }
}
