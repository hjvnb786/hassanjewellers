import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Screens/home.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegister;

  const OtpScreen(
      {super.key, required this.phoneNumber, required this.isRegister});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String verifyId = "";
  TextEditingController otpController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    generateOTP(widget.phoneNumber);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/come.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Container(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.29),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your 6 digit otp!';
                      } else if (value.length < 10) {
                        return 'Your otp is only 6 digits';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'OTP',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      onPressed: () async {
                        await verifyOTP().then((validOTP) {
                          if (validOTP) {
                            if (widget.isRegister) {
                              FirebaseFirestore.instance
                                  .collection("users")
                                  .add({
                                "uid": FirebaseAuth.instance.currentUser?.uid,
                                "phone": widget.phoneNumber
                              });
                            }
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const Home(),
                              ),
                            ); // Added semicolon
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invalid OTP"),
                              ),
                            ); // Added semicolon
                          }
                        }).catchError((error) {
                          // Handle errors here
                          print("error error error");
                          print(error);
                        });
                      },
                      child: const Text('Validate OTP'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      generateOTP(widget.phoneNumber);
                    },
                    child: const Text('Resend OTP'),
                  )
                ],
              ),
            ),
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

  Future<bool> verifyOTP() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verifyId, smsCode: otpController.text);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final currentUser = userCredential.user;

      print("we are about to do it");

      if (currentUser != null) {
        print("we did it");
        return true;
      }

      print("we cant do it, it seems");
      return false;
    } catch (e) {
      // Handle the error (e.g., invalid OTP, network issues)
      print("error");
      print(e);
      return false;
    }
  }
}
