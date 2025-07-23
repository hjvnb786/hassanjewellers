import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_ifsc.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_pan.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/format_ifsc.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/format_pan.dart';

class AdditionalDetailsForm extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const AdditionalDetailsForm({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<AdditionalDetailsForm> createState() => _AdditionalDetailsFormState();
}

class _AdditionalDetailsFormState extends State<AdditionalDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _dobController = TextEditingController();
  final _weddingAnniversaryController = TextEditingController();
  final _bankAccountController = TextEditingController();
  final _bankAccountReenterController = TextEditingController();
  final _bankBranchController = TextEditingController();
  final _ifscController = TextEditingController();
  final _panController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    _dobController.text = widget.formData['dob'] ?? '';
    _weddingAnniversaryController.text = widget.formData['weddingAnniversary'] ?? '';
    _bankAccountController.text = widget.formData['bankAccount'] ?? '';
    _bankAccountReenterController.text = widget.formData['bankAccountReenter'] ?? '';
    _bankBranchController.text = widget.formData['bankBranch'] ?? '';
    _ifscController.text = widget.formData['ifscCode'] ?? '';
    _panController.text = widget.formData['panNumber'] ?? '';
  }

  void _updateFormData() {
    widget.onDataChanged({
      'dob': _dobController.text,
      'weddingAnniversary': _weddingAnniversaryController.text,
      'bankAccount': _bankAccountController.text,
      'bankAccountReenter': _bankAccountReenterController.text,
      'bankBranch': _bankBranchController.text,
      'ifscCode': formatIFSC(_ifscController.text),
      'panNumber': formatPAN(_panController.text),
    });
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
        _updateFormData();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Additional Details (Optional)',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'These details help us provide better service',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          
          // Date of Birth and Wedding Anniversary Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _dobController,
                  decoration: const InputDecoration(
                    labelText: 'Date of Birth',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.cake),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _dobController),
                  onChanged: (value) => _updateFormData(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _weddingAnniversaryController,
                  decoration: const InputDecoration(
                    labelText: 'Wedding Anniversary',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.favorite),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context, _weddingAnniversaryController),
                  onChanged: (value) => _updateFormData(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Bank Account Number
          TextFormField(
            controller: _bankAccountController,
            decoration: const InputDecoration(
              labelText: 'Bank Account Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Re-enter Bank Account Number
          TextFormField(
            controller: _bankAccountReenterController,
            decoration: const InputDecoration(
              labelText: 'Re-enter Bank Account Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_balance),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (value != _bankAccountController.text) {
                  return 'Account numbers do not match';
                }
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Bank Branch and IFSC Code Row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _bankBranchController,
                  decoration: const InputDecoration(
                    labelText: 'Bank Branch',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: (value) => _updateFormData(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _ifscController,
                  decoration: const InputDecoration(
                    labelText: 'IFSC Code',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.code),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!validateIFSC(value)) {
                        return 'Please enter a valid IFSC code';
                      }
                    }
                    return null;
                  },
                  onChanged: (value) => _updateFormData(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // PAN Number
          TextFormField(
            controller: _panController,
            decoration: const InputDecoration(
              labelText: 'PAN Number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.credit_card),
            ),
            textCapitalization: TextCapitalization.characters,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!validatePAN(value)) {
                  return 'Please enter a valid PAN number';
                }
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 20),
          
          // Information Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Why Additional Details?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Personalized birthday offers\n'
                  '• Anniversary celebration discounts\n'
                  '• Secure payment processing\n'
                  '• Faster scheme completion',
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

  @override
  void dispose() {
    _dobController.dispose();
    _weddingAnniversaryController.dispose();
    _bankAccountController.dispose();
    _bankAccountReenterController.dispose();
    _bankBranchController.dispose();
    _ifscController.dispose();
    _panController.dispose();
    super.dispose();
  }
} 