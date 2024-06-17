import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';
import 'package:hassanjewellers/Utils/Services/authentication.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';
import 'package:hassanjewellers/Utils/UI/styles.dart';
import 'package:hassanjewellers/Components/user_exists_dialog.dart';

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

  Route createRoute(verifyId) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => OtpScreen(
        phoneNumber: "+91${phone.text.toString()}",
        isRegister: false,
        verifyId: verifyId,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Account"),
      ),
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
                                  String phoneNumber =
                                      "+91${phone.text.toString()}";
                                  if (_formKey.currentState!.validate()) {
                                    toggleLoading();
                                    String verifyId = "";

                                    checkPhoneExists(phoneNumber)
                                        .then((value) => {
                                              if (!value)
                                                {
                                                  showCustomDialog(
                                                      context,
                                                      "The user is not registered",
                                                      "The phone number you entered is not registered. Please create an account."),
                                                  toggleLoading()
                                                }
                                              else
                                                {
                                                  generateOTP(phoneNumber)
                                                      .then((value) {
                                                    if (value ==
                                                        "too-many-requests") {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              value.toString()),
                                                          backgroundColor:
                                                              Colors.red,
                                                        ),
                                                      );
                                                      return;
                                                    }
                                                    verifyId = value!;
                                                  }).whenComplete(() {
                                                    toggleLoading();
                                                    if (verifyId != "") {
                                                      Navigator.of(context)
                                                          .push(createRoute(
                                                              verifyId));
                                                    }
                                                  })
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
