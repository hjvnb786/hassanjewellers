import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Components/snack_bar.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';
import 'package:hassanjewellers/main.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegister;
  final String verifyId;
  final String? name;
  final String? email;

  const OtpScreen(
      {super.key,
      required this.phoneNumber,
      required this.isRegister,
      required this.verifyId,
      this.name,
      this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Enter your OTP"),
      ),
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
                    decoration:
                        textFieldDecoration("OTP", Icons.message_sharp)),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: elevatedButtonStyle(),
                          onPressed: () {
                            toggleLoading();

                            verifyOTP(widget.verifyId, otpController.text)
                                .then((validOTP) {
                              if (validOTP) {
                                if (widget.isRegister) {
                                  FirebaseFirestore.instance
                                      .collection("users")
                                      .add({
                                    "uid":
                                        FirebaseAuth.instance.currentUser?.uid,
                                    "phone": widget.phoneNumber,
                                    "email": widget.email,
                                    "name": widget.name
                                  });
                                }

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MyApp()),
                                  (Route<dynamic> route) =>
                                      false, // This predicate ensures all routes are removed
                                );
                              } else {
                                displaySnackBar(
                                    context, "Invalid OTP"); // Added semicolon
                              }
                            }).catchError((error) {
                              displaySnackBar(context, "Something went wrong");
                            }).whenComplete(() => toggleLoading());
                          },
                          child: const Text('Validate OTP'),
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    generateOTP(widget.phoneNumber);
                  },
                  child: const Text('0:60 Resend OTP', style: TextStyle(color: Colors.grey),),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
