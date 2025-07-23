import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hassanjewellers/Helpers/handle_OTP.dart';
import 'package:hassanjewellers/Services/firebase_services/registerUser.dart';
import 'package:hassanjewellers/Services/firebase_services/signInWithCustomToken.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';
import 'package:hassanjewellers/main.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isRegister;
  final String name;
  final String email;
  final String uid;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    required this.isRegister,
    required this.name,
    required this.email,
    required this.uid,
  });

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 32),

                  // Header
                  Text(
                    "Verification Code",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "We've sent a verification code to",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // OTP Input Card
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Enter OTP",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              4,
                              (index) => Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                width: 50,
                                height: 50,
                                child: TextFormField(
                                  onChanged: (value) {
                                    if (value.length == 1) {
                                      otpController.text =
                                          otpController.text + value;
                                      if (index < 3) {
                                        FocusScope.of(context).nextFocus();
                                      }
                                    }
                                    if (value.isEmpty && index > 0) {
                                      otpController.text = otpController.text
                                          .substring(
                                              0, otpController.text.length - 1);
                                      FocusScope.of(context).previousFocus();
                                    }
                                  },
                                  onSaved: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      otpController.text =
                                          otpController.text + value;
                                    }
                                  },
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    height: 1.5,
                                  ),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(1),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    counterText: "",
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                toggleLoading();
                                handleOTP(
                                  mobileNumber: widget.phoneNumber,
                                  otp: otpController.text,
                                  uid: widget.uid,
                                ).then((response) async {
                                  print("otp_screen: handleOTP response: $response");
                                  print("isRegister: ${widget.isRegister}");

                                  if (response['status'] == "SUCCESS") {
                                    if (response.containsKey('token')) {
                                      print("Starting Firebase sign-in attempt...");
                                      signInWithCustomToken(response['token'])
                                          .then((userCredential) {
                                        if (userCredential.user == null) {
                                          throw "Firebase sign-in completed but user is null";
                                        }
                                        
                                        print("Firebase sign-in successful with user ID: ${userCredential.user?.uid}");
                                        
                                        if (widget.isRegister) {
                                          // For registration, create the user in Firestore
                                          final User? currentUser = getCurrentUser();
                                          if (currentUser == null) {
                                            throw "Firebase user is not available. Please try again.";
                                          }
                                          
                                          print("Attempting to register user with uid: ${currentUser.uid}");
                                          return registerUser(
                                            currentUser.uid,
                                            widget.name,
                                            widget.phoneNumber,
                                            widget.email,
                                          );
                                        }
                                        return Future.value(); // Return empty future for non-registration case
                                      }).then((_) {
                                        print("User registration successful");
                                        // Navigate to main app for both login and register
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(builder: (context) => MyApp()),
                                          (Route<dynamic> route) => false,
                                        );
                                      }).catchError((error) {
                                        print("Error during Firebase operations: $error");
                                        toggleLoading();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Authentication failed: ${error.toString()}'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      });
                                    } else {
                                      toggleLoading();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Invalid response from server'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  } else {
                                    toggleLoading();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(response['error'] ?? 'Verification failed'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Error: $error'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }).whenComplete(() => toggleLoading());
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              "Verify",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Resend Timer/Button
                  if (!resendOtpEnabled)
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          children: [
                            const TextSpan(
                                text: "Didn't receive the code? Try again in "),
                            TextSpan(
                              text: "$counter seconds",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Center(
                      child: TextButton(
                        onPressed: () {
                          if (resendOtpEnabled) {
                            handleOTP(mobileNumber: widget.phoneNumber)
                                .then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('OTP sent successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              setState(() {
                                counter = 30;
                                resendOtpEnabled = false;
                                resendOTPTimer();
                              });
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $error'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            });
                          }
                        },
                        child: Text(
                          "Resend Code",
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}
