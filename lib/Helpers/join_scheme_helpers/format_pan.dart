String formatPAN(String pan) {
  // Convert to uppercase and remove spaces
  return pan.toUpperCase().replaceAll(' ', '');
} 