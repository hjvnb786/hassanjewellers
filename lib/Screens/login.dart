import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';

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
            child: ListView(
              children: [
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Column(
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
                                      verifyId = value!;
                                    }).whenComplete(() {
                                      toggleLoading();
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
                                    });
                                  }
                                }
                              : () {},
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 15)),
                          child: const Text("Login"),
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
                    Navigator.of(context).pop();
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text("Not a customer, Register."),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
