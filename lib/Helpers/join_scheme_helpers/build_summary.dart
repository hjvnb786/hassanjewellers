String buildSummary(Map<String, dynamic> formData) {
  StringBuffer summary = StringBuffer();
  
  // User Details Section
  summary.writeln('📋 USER DETAILS');
  summary.writeln('First Name: ${formData['firstName'] ?? 'Not provided'}');
  summary.writeln('Last Name: ${formData['lastName'] ?? 'Not provided'}');
  summary.writeln('Mobile: ${formData['mobile'] ?? 'Not provided'}');
  summary.writeln('Email: ${formData['email'] ?? 'Not provided'}');
  summary.writeln('Address: ${formData['address'] ?? 'Not provided'}');
  summary.writeln('');
  
  // Scheme Details Section
  summary.writeln('💰 SCHEME DETAILS');
  summary.writeln('Scheme Name: ${formData['schemeName'] ?? 'Not provided'}');
  summary.writeln('Scheme Amount: ${formData['schemeAmount'] ?? 'Not provided'}');
  summary.writeln('');
  
  // Additional Details Section
  summary.writeln('📝 ADDITIONAL DETAILS');
  summary.writeln('Date of Birth: ${formData['dob'] ?? 'Not provided'}');
  summary.writeln('Wedding Anniversary: ${formData['weddingAnniversary'] ?? 'Not provided'}');
  summary.writeln('Bank Account: ${formData['bankAccount'] ?? 'Not provided'}');
  summary.writeln('Bank Branch: ${formData['bankBranch'] ?? 'Not provided'}');
  summary.writeln('IFSC Code: ${formData['ifscCode'] ?? 'Not provided'}');
  summary.writeln('PAN Number: ${formData['panNumber'] ?? 'Not provided'}');
  
  return summary.toString();
} 