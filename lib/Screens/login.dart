import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/otp_screen.dart';

class Login extends StatelessWidget {
  Login({super.key});

  final TextEditingController phone = TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
      child: Form(
        key: _formKey,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.29),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 30),
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpScreen(
                                    phoneNumber: "+91${phone.text.toString()}",
                                    isRegister: false),
                              ));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15)),
                      child: const Text("Login"),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text("Not a customer, Register."),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
