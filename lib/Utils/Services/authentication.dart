import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

Future<String> fetchToken() async {
  final url =
      Uri.parse('https://spt.uvm.mybluehostin.me/api/auth/createToken.php');
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Parse the JSON response
      final data = json.decode(response.body);
      print('Data: $data');
      return data["customToken"];
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
      return "";
    }
  } catch (e) {
    print("its going on error baby");
    print('Error: $e');
    return "";
  }
}

Future<String?> generateOTP(String phone) async {
  print("generate OTP triggered");
  final completer = Completer<String?>();

  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException firebaseAuthException) {
        print("exception occurred");
        completer.complete(firebaseAuthException.code);
      },
      codeSent: (String verificationId, int? resendToken) {
        print("verification id sent successfully");
        completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );

    return completer.future;
  } catch (e) {
    completer.completeError("something went wrong, please try again");
    return completer.future;
  }
}

Future<bool> verifyOTP(String verifyId, String otp) async {
  try {
    PhoneAuthCredential credential =
        PhoneAuthProvider.credential(verificationId: verifyId, smsCode: otp);

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final currentUser = userCredential.user;

    if (currentUser != null) {
      return true;
    }

    return false;
  } catch (e) {
    return false;
  }
}
