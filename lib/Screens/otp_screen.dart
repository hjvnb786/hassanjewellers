import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Utils/Helpers/handle_OTP.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';
import 'package:hassanjewellers/main.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegister;
  //final String verifyId;
  final String name;
  final String email;
  final String uid;

  const OtpScreen(
      {super.key,
      required this.phoneNumber,
      required this.isRegister,
      //required this.verifyId,
      required this.name,
      required this.email,
      required this.uid});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();
  int counter = 30;
  bool resendOtpEnabled = false;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    resendOTPTimer();
  }

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void resendOTPTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (counter >= 1) {
          print(counter);
          counter--;
        } else {
          resendOtpEnabled = true;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent the screen from resizing

      appBar: AppBar(
        title: const Text("Enter Verification Code"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const SizedBox(height: 100),
                    Text(
                      "We have sent the verification code to your phone number ${widget.phoneNumber}",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
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
                                print("OTP button pressed");
                                toggleLoading();

                                print("phone: ${widget.phoneNumber}");
                                print("otp: ${otpController.text}");

                                Future<String> authStatus = handleOTP(
                                  mobileNumber: widget.phoneNumber,
                                  otp: otpController.text,
                                  uid: widget.uid,
                                );

                                authStatus.then((value) {
                                  print("Authentication status: $value");
                                  if (value == "SUCCESS") {
                                    if (widget.isRegister) {
                                      registerUser(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          widget.name,
                                          widget.phoneNumber,
                                          widget.email);
                                    }

                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MyApp()),
                                      (Route<dynamic> route) => false,
                                    );
                                  } else {
                                    // Handle other outcomes if necessary
                                    print("Authentication failed");
                                  }
                                }).catchError((error) {
                                  // Handle any errors that might occur during the future's execution
                                  print("An error occurred: $error");
                                }).whenComplete(() {
                                  // Toggle loading off after the future completes
                                  toggleLoading();
                                });
                              },
                              child: const Text('Submit OTP'),
                            ),
                          ),
                          Visibility(
                            visible: isLoading,
                            child: const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child:
                                  LinearProgressIndicator(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              Visibility(
                visible: !resendOtpEnabled,
                child: Text(
                  "If you have not received the OTP, You can try again in $counter seconds.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (resendOtpEnabled) {
                      generateOTP(widget.phoneNumber);
                      setState(() {
                        counter = 30;
                        resendOtpEnabled = false;
                        resendOTPTimer();
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    backgroundColor: resendOtpEnabled ? null : Colors.grey[100],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Adjust the radius as needed
                    ),
                  ),
                  child: Text(
                    "Resend OTP",
                    style: resendOtpEnabled
                        ? const TextStyle(color: Colors.deepPurple)
                        : const TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
