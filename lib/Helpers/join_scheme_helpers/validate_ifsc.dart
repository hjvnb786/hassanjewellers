bool validateIFSC(String ifsc) {
  // IFSC code validation (4 letters + 7 alphanumeric)
  final ifscRegex = RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$');
  return ifscRegex.hasMatch(ifsc.toUpperCase());
} 