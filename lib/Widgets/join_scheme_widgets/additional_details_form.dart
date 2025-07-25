import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_ifsc.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_pan.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/format_ifsc.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/format_pan.dart';
import '../../Services/firebase_services/getAdditionalFields.dart';
import '../additional_details_shimmer_loading.dart';

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
  final Map<String, TextEditingController> _controllers = {};
  
  List<AdditionalField> _fields = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _fetchAdditionalFields();
  }

  void _loadExistingData() {
    // Load existing data for all fields
    for (final field in _fields) {
      final controller = TextEditingController();
      controller.text = widget.formData[field.name] ?? '';
      _controllers[field.name] = controller;
    }
  }

  Future<void> _fetchAdditionalFields() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Fetching additional fields in form...');
      final fields = await getAdditionalFields();
      print('Received ${fields.length} additional fields in form');
      print('Fields details: ${fields.map((f) => '${f.name}: ${f.label}').toList()}');
      
      setState(() {
        _fields = fields;
        _isLoading = false;
      });

      print('State updated - _fields length: ${_fields.length}');
      print('State updated - _isLoading: $_isLoading');

      // Initialize controllers for all fields
      for (final field in _fields) {
        final controller = TextEditingController();
        controller.text = widget.formData[field.name] ?? '';
        _controllers[field.name] = controller;
      }
    } catch (e) {
      print('Error in _fetchAdditionalFields: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load additional fields. Please try again.';
      });
    }
  }

  void _updateFormData() {
    final Map<String, dynamic> formData = {};
    for (final field in _fields) {
      final controller = _controllers[field.name];
      if (controller != null) {
        String value = controller.text;
        
        // Apply formatting based on field type
        if (field.name == 'ifscCode') {
          value = formatIFSC(value);
        } else if (field.name == 'panNumber') {
          value = formatPAN(value);
        }
        
        formData[field.name] = value;
      }
    }
    widget.onDataChanged(formData);
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

  IconData _getIconForField(String? iconName) {
    switch (iconName) {
      case 'cake':
        return Icons.cake;
      case 'favorite':
        return Icons.favorite;
      case 'account_balance':
        return Icons.account_balance;
      case 'business':
        return Icons.business;
      case 'code':
        return Icons.code;
      case 'credit_card':
        return Icons.credit_card;
      case 'email':
        return Icons.email;
      case 'phone':
        return Icons.phone;
      case 'person':
        return Icons.person;
      default:
        return Icons.edit;
    }
  }

  Color _getIconColorForField(String? iconName) {
    switch (iconName) {
      case 'cake':
        return const Color(0xFFE91E63);
      case 'favorite':
        return const Color(0xFFF44336);
      case 'account_balance':
        return const Color(0xFF4CAF50);
      case 'business':
        return const Color(0xFF2196F3);
      case 'code':
        return const Color(0xFF9C27B0);
      case 'credit_card':
        return const Color(0xFFFF9800);
      case 'email':
        return const Color(0xFF607D8B);
      case 'phone':
        return const Color(0xFF795548);
      case 'person':
        return const Color(0xFF1976D2);
      default:
        return const Color(0xFF1976D2);
    }
  }

  Color _getBackgroundColorForField(String? iconName) {
    switch (iconName) {
      case 'cake':
        return const Color(0xFFFCE4EC);
      case 'favorite':
        return const Color(0xFFFFEBEE);
      case 'account_balance':
        return const Color(0xFFE8F5E8);
      case 'business':
        return const Color(0xFFE3F2FD);
      case 'code':
        return const Color(0xFFF3E5F5);
      case 'credit_card':
        return const Color(0xFFFFF3E0);
      case 'email':
        return const Color(0xFFECEFF1);
      case 'phone':
        return const Color(0xFFEFEBE9);
      case 'person':
        return const Color(0xFFE3F2FD);
      default:
        return const Color(0xFFE3F2FD);
    }
  }

  String? Function(String?)? _getValidatorForField(AdditionalField field) {
    return (value) {
      if (field.isRequired && (value == null || value.trim().isEmpty)) {
        return 'This field is required';
      }
      
      if (value != null && value.isNotEmpty) {
        switch (field.validation) {
          case 'ifsc':
            if (!validateIFSC(value)) {
              return 'Please enter a valid IFSC code';
            }
            break;
          case 'pan':
            if (!validatePAN(value)) {
              return 'Please enter a valid PAN number';
            }
            break;
          case 'email':
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            break;
          case 'phone':
            if (!RegExp(r'^[0-9]{10}$').hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
              return 'Please enter a valid phone number';
            }
            break;
        }
      }
      return null;
    };
  }

  Widget _buildDynamicField(AdditionalField field) {
    final controller = _controllers[field.name];
    if (controller == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Row(
            children: [
              Icon(
                _getIconForField(field.icon),
                color: _getIconColorForField(field.icon),
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                field.label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (field.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: Colors.red[400],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          
          // Field
          if (field.type == 'dropdown' && field.options != null)
            DropdownButtonFormField<String>(
              value: controller.text.isEmpty ? null : controller.text,
              decoration: InputDecoration(
                hintText: field.placeholder ?? 'Select ${field.label}',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _getIconColorForField(field.icon),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[300]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[500]!, width: 2),
                ),
                suffixIcon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ),
              items: field.options!.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              validator: _getValidatorForField(field),
              onChanged: (String? newValue) {
                controller.text = newValue ?? '';
                _updateFormData();
              },
              dropdownColor: Colors.white,
              icon: const SizedBox.shrink(),
              menuMaxHeight: 200,
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
            )
          else
            TextFormField(
              controller: controller,
              keyboardType: _getKeyboardTypeForField(field.type),
              textCapitalization: _getTextCapitalizationForField(field.type),
              readOnly: field.type == 'date',
              validator: _getValidatorForField(field),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: field.placeholder ?? 'Enter ${field.label.toLowerCase()}',
                hintStyle: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 16,
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: _getIconColorForField(field.icon),
                    width: 2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[200]!),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[300]!),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[500]!, width: 2),
                ),
                suffixIcon: field.type == 'date' 
                    ? Icon(Icons.calendar_today, color: Colors.grey[600])
                    : null,
              ),
              onTap: field.type == 'date' 
                  ? () => _selectDate(context, controller)
                  : null,
              onChanged: (value) => _updateFormData(),
            ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardTypeForField(String type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }

  TextCapitalization _getTextCapitalizationForField(String type) {
    switch (type) {
      case 'ifsc':
      case 'pan':
        return TextCapitalization.characters;
      default:
        return TextCapitalization.none;
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Building AdditionalDetailsForm - _isLoading: $_isLoading, _fields length: ${_fields.length}, _errorMessage: $_errorMessage');
    
    return Form(
      key: _formKey,
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
                      if (_isLoading)
                        const AdditionalDetailsShimmerLoading()
                      else if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                              TextButton(
                                onPressed: _fetchAdditionalFields,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Header
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
                        
                        // Dynamic fields
                        if (_fields.isNotEmpty) ...[
                          Text('Rendering ${_fields.length} dynamic fields'),
                          ..._fields.map((field) => _buildDynamicField(field)),
                        ] else ...[
                          Text('No fields to render - _fields is empty'),
                        ],
                        
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
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Why Additional Details?',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                      fontSize: 16,
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
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
} 