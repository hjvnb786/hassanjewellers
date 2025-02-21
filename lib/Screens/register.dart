import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/show_custom_dialog.dart';
import 'package:hassanjewellers/Screens/login.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';
import 'package:hassanjewellers/Utils/Helpers/animated_route.dart';
import 'package:hassanjewellers/Utils/Helpers/handle_OTP.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phone = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool prefixEnabledState = false;

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  Future<void> handleRegister() async {
    String phoneNumber = "+91${phone.text}";

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Start Loading
    toggleLoading();

    // Check if phone number exists
    bool phoneExists = await checkPhoneExist(phoneNumber);

    if (!phoneExists) {
      toggleLoading(); // Stop loading if user already registered

      if (!mounted) {
        return;
      }

      showCustomDialog(
        context,
        "The user is already registered",
        "The phone number you entered is already registered.",
      );
      return;
    }

    // Send OTP
    String otpStatus = await handleOTP(mobileNumber: phoneNumber);

    if (otpStatus == "FAILURE") {
      toggleLoading(); // Stop loading on failure
      return;
    }

    if (!mounted) return;

    // Navigate to OTP Screen
    Navigator.of(context).push(
      animatedRoute(
        OtpScreen(
          phoneNumber: phoneNumber,
          isRegister: true,
          uid: "",
          name: name.text,
          email: email.text,
        ),
        context,
      ),
    );

    toggleLoading(); // Optionally stop loading after navigation if needed

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
        title: const Text("Create Your Account"),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListView(
              children: [
                const SizedBox(height: 20),
                TextFormField(
                    keyboardType: TextInputType.name,
                    controller: name,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your Name';
                      } else if (value.length < 5) {
                        return 'Your name should be least 5 digits';
                      }
                      return null;
                    },
                    decoration: textFieldDecoration("name", Icons.face)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    onTap: () {
                      setState(() {
                        prefixEnabledState = true;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your phone please!';
                      } else if (value.length < 10) {
                        return 'Please enter your 10 digit phone number';
                      }
                      return null;
                    },
                    decoration: textFieldDecoration("phone", Icons.phone,
                        prefixEnabled: prefixEnabledState, context: context)),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your Mail Please';
                      } else if (value.contains("@") == false) {
                        return 'Enter your Mail Correctly';
                      }
                      return null;
                    },
                    decoration: textFieldDecoration("mail", Icons.mail)),
                const SizedBox(height: 12),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: handleRegister,
                          style: elevatedButtonStyle(),
                          child: const Text('Register')),
                    ),
                    Visibility(
                      visible: isLoading,
                      child: const Padding(
                        padding: EdgeInsets.only(top: 10),
                        child: LinearProgressIndicator(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context)
                        .push(animatedRoute(const Login(), context));
                  },
                  child: const Text("Already a customer? Log in."),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
