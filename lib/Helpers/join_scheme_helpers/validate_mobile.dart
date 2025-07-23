bool validateMobile(String mobile) {
  // Indian mobile number validation (10 digits starting with 6-9)
  final mobileRegex = RegExp(r'^[6-9]\d{9}$');
  return mobileRegex.hasMatch(mobile);
} 