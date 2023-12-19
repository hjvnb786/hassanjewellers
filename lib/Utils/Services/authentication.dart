import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

Future<String?> generateOTP(String phone) async {
  final completer = Completer<String?>();

  try {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) {},
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
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
