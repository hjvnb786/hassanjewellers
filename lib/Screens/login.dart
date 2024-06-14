import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phone = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;

  void toggleLoading() {
    setState(() {
      isLoading = !isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding:
              EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.29),
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ListView(
                children: [
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
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading == false
                              ? () {
                                  if (_formKey.currentState!.validate()) {
                                    toggleLoading();
                                    String verifyId = "";
                                    generateOTP("+91${phone.text.toString()}")
                                        .then((value) {
                                      if (value == "too-many-requests") {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(value.toString()),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      verifyId = value!;
                                    }).whenComplete(() {
                                      toggleLoading();
                                      if (verifyId != "") {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OtpScreen(
                                                phoneNumber:
                                                    "+91${phone.text.toString()}",
                                                isRegister: false,
                                                verifyId: verifyId,
                                              ),
                                            ));
                                      }
                                    });
                                  }
                                }
                              : () {},
                          style: elevatedButtonStyle(),
                          child: const Text("Login"),
                        ),
                      ),
                      Visibility(
                        visible: isLoading,
                        child: const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: LinearProgressIndicator(
                              color: Colors.deepPurpleAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Not a customer, Register."),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
