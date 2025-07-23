bool validatePAN(String pan) {
  // PAN number validation (10 alphanumeric characters)
  final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
  return panRegex.hasMatch(pan.toUpperCase());
} 