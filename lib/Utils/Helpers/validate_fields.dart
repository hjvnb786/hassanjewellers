
String? validateName(String? value) {
  if (value == null || value.isEmpty) {
    return "Name cannot be empty. Please enter a valid name.";
  } else if (value.length < 5) {
    return "Name should be at least 5 characters long. Please enter a valid name.";
  } else if (!RegExp(r"^[a-zA-Z]+$").hasMatch(value)) {
    return "Invalid characters in the name. Please use only letters.";
  } else if (value.length > 50) {
    return "Name is too long. Please enter a shorter name.";
  }
  // Add more edge cases as needed

  return null; // Validation passed
}

String? validateGuardianName(String? guardianName) {
  if (guardianName == null || guardianName.isEmpty) {
    return "Guardian name cannot be empty. Please enter a valid name.";
  } else if (guardianName.length < 5) {
    return "Guardian name should be at least 5 characters long. Please enter a valid name.";
  } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(guardianName)) {
    return "Invalid characters in the guardian name. Please use only letters and spaces.";
  } else if (guardianName.length > 50) {
    return "Guardian name is too long. Please enter a shorter name.";
  }
  // Add more edge cases as needed

  return null; // Validation passed
}

String? validateNomineeName(String? nomineeName) {
  if (nomineeName == null || nomineeName.isEmpty) {
    return "Nominee name cannot be empty. Please enter a valid name.";
  } else if (nomineeName.length < 5) {
    return "Nominee name should be at least 5 characters long. Please enter a valid name.";
  } else if (!RegExp(r"^[a-zA-Z\s]+$").hasMatch(nomineeName)) {
    return "Invalid characters in the nominee name. Please use only letters and spaces.";
  } else if (nomineeName.length > 50) {
    return "Nominee name is too long. Please enter a shorter name.";
  }
  // Add more edge cases as needed

  return null; // Validation passed
}

String? validateAddress(String? address) {
  if (address == null || address.isEmpty) {
    return "Address cannot be empty. Please enter a valid address.";
  } else if (address.length < 10) {
    return "Address should be at least 10 characters long. Please enter a valid address.";
  } else if (address.length > 255) {
    return "Address is too long. Please enter a shorter address.";
  }
  // Add more edge cases as needed

  return null; // Validation passed
}

String? validateAge(String? age) {
  if (age == null || age.isEmpty) {
    return "Age cannot be empty. Please enter a valid age.";
  }

  int? ageValue;
  try {
    ageValue = int.parse(age);
  } catch (e) {
    return "Invalid age format. Please enter a valid numeric age.";
  }

  if (ageValue <= 0) {
    return "Age must be a positive integer. Please enter a valid age.";
  } else if (ageValue <= 18) {
    return "Age must be above 18. Please enter a valid age.";
  } else if (ageValue > 120) {
    return "Age seems to be too high. Please verify and enter a valid age.";
  }
  // Add more edge cases as needed

  return null; // Validation passed
}

String? validateAlternativeMobile(String? alternativeMobile) {
  if (alternativeMobile == null || alternativeMobile.isEmpty) {
    return "Alternative mobile number cannot be empty. Please enter a valid number.";
  }

  // Check if the alternative mobile number is a valid numeric value
  if (!RegExp(r"^[0-9]+$").hasMatch(alternativeMobile)) {
    return "Invalid characters in the alternative mobile number. Please use only numbers.";
  }

  // Check the length of the alternative mobile number
  if (alternativeMobile.length < 10 || alternativeMobile.length > 15) {
    return "Alternative mobile number should be between 10 and 15 digits. Please enter a valid number.";
  }

  // Add more edge cases as needed

  return null; // Validation passed
}

