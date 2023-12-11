import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/login.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';

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

  Future<bool> checkDocumentExists(String fieldValue) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users') // Ensure this is the correct collection name
        .where("phone", isEqualTo: fieldValue)
        .limit(1)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  void showUserExistsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('User Already Registered'),
          content: const Text(
              'This phone number is already registered. Please login.'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            'assets/talha.png',
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.24),
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
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
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
                      controller: phone,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your Mail Please!';
                        } else if (value.length < 10) {
                          return 'Please enter your 10 digit phone number';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: TextFormField(
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
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          String phoneNumber = "+91${phone.text}";

                          bool userExists =
                              await checkDocumentExists(phoneNumber);
                          if (userExists) {
                            showUserExistsDialog();
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    OtpScreen(phoneNumber: phoneNumber, isRegister: true),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text('Register'),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Login(),
                          ));
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Already a customer, login."),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
