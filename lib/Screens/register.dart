import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/user_exists_dialog.dart';
import 'package:hassanjewellers/Screens/login.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';
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

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  void handleRegister() {
    if (_formKey.currentState!.validate()) {
      toggleLoading();
      String phoneNumber = "+91${phone.text}";

      //check phone number exists
      checkPhoneExists(phoneNumber).then((phoneExists) {
        if (phoneExists) {
          showUserExistsDialog(context);
          toggleLoading();
        }
        // if phone number doesn't exist
        else {
          String verifyId = "";
          generateOTP(phoneNumber).then((value) {
            verifyId = value!;
          }).whenComplete(() {
            toggleLoading();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OtpScreen(
                  phoneNumber: phoneNumber,
                  isRegister: true,
                  verifyId: verifyId,
                  name: name.text,
                  email: email.text,
                ),
              ),
            );
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: ListView(
              children: [
                const Text(
                  "Create account",
                  style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Please enter your details",
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Name',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
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
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Phone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                TextFormField(
                    controller: phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Enter your phone please!';
                      } else if (value.length < 10) {
                        return 'Please enter your 10 digit phone number';
                      }
                      return null;
                    },
                    decoration: textFieldDecoration("phone", Icons.phone)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Login(),
                      ),
                    );
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
