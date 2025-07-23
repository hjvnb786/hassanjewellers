String formatIFSC(String ifsc) {
  // Convert to uppercase and remove spaces
  return ifsc.toUpperCase().replaceAll(' ', '');
} 