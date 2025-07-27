import 'package:flutter/material.dart';

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
                      
                      // User Details Card
                      _buildUserDetailsCard(),
                      const SizedBox(height: 16),
                      
                      // Scheme Details Card
                      _buildSchemeDetailsCard(),
                      const SizedBox(height: 16),
                      
                      // Additional Details Card
                      _buildAdditionalDetailsCard(),
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

  Widget _buildSchemeDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF388E3C).withOpacity(0.3), // Green border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: const Color(0xFF388E3C), // Green icon
              ),
              const SizedBox(width: 8),
              Text(
                'Scheme Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF388E3C), // Green text
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernDetailRow(Icons.account_balance_wallet, 'Scheme Name', (formData['schemeName'] ?? '').toString()),
          _buildModernDetailRow(Icons.attach_money, 'Scheme Amount', (formData['schemeAmount'] ?? '').toString()),
          _buildModernDetailRow(Icons.schedule, 'Scheme Duration', (formData['schemeDuration'] ?? '').toString()),
          _buildModernDetailRow(Icons.calendar_today, 'Start Date', (formData['startDate'] ?? '').toString()),
          _buildModernDetailRow(Icons.event, 'End Date', (formData['endDate'] ?? '').toString()),
          _buildModernDetailRow(Icons.payment, 'Payment Frequency', (formData['paymentFrequency'] ?? '').toString()),
          _buildModernDetailRow(Icons.trending_up, 'Interest Rate', (formData['interestRate'] ?? '').toString()),
          _buildModernDetailRow(Icons.description, 'Scheme Description', (formData['schemeDescription'] ?? '').toString()),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsCard() {
    // Get all fields from formData that are not standard fields
    final standardFields = [
      'firstName', 'lastName', 'mobile', 'email', 'address', 
      'schemeName', 'schemeAmount', 'schemeDuration', 'startDate', 
      'endDate', 'paymentFrequency', 'interestRate', 'schemeDescription'
    ];
    final additionalFields = <String, Map<String, String>>{};
    
    // Dynamically get all additional fields from formData
    formData.forEach((key, value) {
      if (!standardFields.contains(key) && 
          !key.endsWith('_label') && // Skip label fields
          value != null && 
          value.toString().isNotEmpty) {
        
        // Get the label for this field
        final labelKey = '${key}_label';
        final label = formData[labelKey] ?? key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim();
        
        additionalFields[key] = {
          'label': label,
          'value': value.toString(),
        };
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
              entry.value['label']!, 
              entry.value['value']!
            )
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.3), // Blue border
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                color: const Color(0xFF1976D2), // Blue icon
              ),
              const SizedBox(width: 8),
              Text(
                'User Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1976D2), // Blue text
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernDetailRow(Icons.person, 'First Name', (formData['firstName'] ?? '').toString()),
          _buildModernDetailRow(Icons.person, 'Last Name', (formData['lastName'] ?? '').toString()),
          _buildModernDetailRow(Icons.phone, 'Mobile Number', (formData['mobile'] ?? '').toString()),
          _buildModernDetailRow(Icons.email, 'Email Address', (formData['email'] ?? '').toString()),
          _buildModernDetailRow(Icons.location_on, 'Address', (formData['address'] ?? '').toString()),
        ],
      ),
    );
  }

  Widget _buildModernDetailRow(IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
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
} 