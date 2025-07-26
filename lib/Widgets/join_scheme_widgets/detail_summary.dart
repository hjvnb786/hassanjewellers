import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/build_summary.dart';

class DetailSummary extends StatelessWidget {
  final Map<String, dynamic> formData;
  final VoidCallback onConfirm;

  const DetailSummary({
    super.key,
    required this.formData,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final summaryText = buildSummary(formData);

    return Form(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Form Container similar to other forms
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Header
                      Text(
                        'Detail Summary',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please review your information before proceeding',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Summary Content
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF388E3C).withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.summarize,
                                  color: const Color(0xFF388E3C),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Form Summary',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF388E3C),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              summaryText,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.6,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Confirmation Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Ready to Proceed',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'All mandatory fields have been completed. You can now proceed to the payment page to complete your scheme registration.',
                              style: TextStyle(
                                color: Colors.grey[700],
                                height: 1.5,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Action Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onConfirm,
                          icon: const Icon(Icons.payment),
                          label: const Text(
                            'Proceed to Payment',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Terms and Conditions
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'By proceeding, you agree to our terms and conditions for scheme participation.',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    // Get all fields from formData that are not standard fields
    final standardFields = ['firstName', 'lastName', 'mobile', 'email', 'address', 'schemeName', 'schemeAmount'];
    final additionalFields = <String, String>{};
    
    // Dynamically get all additional fields from formData
    formData.forEach((key, value) {
      if (!standardFields.contains(key) && 
          value != null && 
          value.toString().isNotEmpty) {
        additionalFields[key] = value.toString();
      }
    });

    // If no additional fields, don't show the card
    if (additionalFields.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5), // Light purple background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7B1FA2).withOpacity(0.3), // Purple border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_note_outlined,
                color: const Color(0xFF7B1FA2), // Purple icon
              ),
              const SizedBox(width: 8),
              Text(
                'Additional Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF7B1FA2), // Purple text
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Dynamically build rows for each additional field
          ...additionalFields.entries.map((entry) => 
            _buildModernDetailRow(
              Icons.edit, 
              _formatFieldName(entry.key), 
              entry.value
            )
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFieldName(String key) {
    switch (key) {
      case 'firstName':
        return 'First Name';
      case 'lastName':
        return 'Last Name';
      case 'mobile':
        return 'Mobile Number';
      case 'email':
        return 'Email Address';
      case 'address':
        return 'Address';
      case 'schemeName':
        return 'Scheme Name';
      case 'schemeAmount':
        return 'Scheme Amount';
      default:
        return key.replaceAll('_', ' ').toUpperCase();
    }
  }
} 