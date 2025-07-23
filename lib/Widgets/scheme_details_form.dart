import 'package:flutter/material.dart';

class SchemeDetailsForm extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const SchemeDetailsForm({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<SchemeDetailsForm> createState() => _SchemeDetailsFormState();
}

class _SchemeDetailsFormState extends State<SchemeDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedSchemeName;
  String? _selectedSchemeAmount;

  final List<String> _schemeNames = [
    'Gold Savings Scheme',
    'Silver Investment Plan',
    'Diamond Collection Scheme',
    'Platinum Premium Plan',
    'Wedding Collection Scheme',
    'Festival Savings Plan',
  ];

  final List<String> _schemeAmounts = [
    '₹5,000',
    '₹10,000',
    '₹25,000',
    '₹50,000',
    '₹1,00,000',
    '₹2,50,000',
    '₹5,00,000',
  ];

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _selectedSchemeName = widget.formData['schemeName'];
    _selectedSchemeAmount = widget.formData['schemeAmount'];
  }

  void _updateFormData() {
    widget.onDataChanged({
      'schemeName': _selectedSchemeName,
      'schemeAmount': _selectedSchemeAmount,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Scheme Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // Scheme Name Dropdown
          DropdownButtonFormField<String>(
            value: _selectedSchemeName,
            decoration: const InputDecoration(
              labelText: 'Scheme Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance_wallet),
            ),
            items: _schemeNames.map((String scheme) {
              return DropdownMenuItem<String>(
                value: scheme,
                child: Text(scheme),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a scheme';
              }
              return null;
            },
            onChanged: (String? newValue) {
              setState(() {
                _selectedSchemeName = newValue;
                _updateFormData();
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Scheme Amount Dropdown
          DropdownButtonFormField<String>(
            value: _selectedSchemeAmount,
            decoration: const InputDecoration(
              labelText: 'Scheme Amount *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            items: _schemeAmounts.map((String amount) {
              return DropdownMenuItem<String>(
                value: amount,
                child: Text(amount),
              );
            }).toList(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select an amount';
              }
              return null;
            },
            onChanged: (String? newValue) {
              setState(() {
                _selectedSchemeAmount = newValue;
                _updateFormData();
              });
            },
          ),
          const SizedBox(height: 20),
          
          // Scheme Information Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Scheme Information',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Monthly installment payments\n'
                  '• Flexible payment options\n'
                  '• Secure investment in precious metals\n'
                  '• Professional jewelry consultation\n'
                  '• Delivery at scheme completion',
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 