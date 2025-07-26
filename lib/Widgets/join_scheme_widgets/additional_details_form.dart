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
  final Function(bool)? onValidationChanged; // Add validation callback

  const AdditionalDetailsForm({
    super.key,
    required this.formData,
    required this.onDataChanged,
    this.onValidationChanged,
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
    _fetchAdditionalFields();
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _fetchAdditionalFields() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Fetching additional fields in form...');
      
      // Print raw data first
      await printRawData();
      
      final fields = await getAdditionalFields();
      print('Received ${fields.length} additional fields in form');
      
      setState(() {
        _fields = fields;
        _isLoading = false;
      });

      // Initialize controllers for all fields (including nested ones)
      _initializeControllers(fields);

    } catch (e) {
      print('Error in _fetchAdditionalFields: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load additional fields. Please try again.';
      });
    }
  }

  void _initializeControllers(List<AdditionalField> fields) {
    for (final field in fields) {
      if (field.type == 'group' && field.fields != null) {
        // Initialize controllers for group fields
        field.fields!.forEach((subFieldName, subField) {
          final controller = TextEditingController();
          controller.text = widget.formData[subField.name] ?? '';
          _controllers[subField.name] = controller;
        });
      } else {
        // Initialize controller for regular field
        final controller = TextEditingController();
        controller.text = widget.formData[field.name] ?? '';
        _controllers[field.name] = controller;
      }
    }
    
    // Check initial validation state
    _checkValidation();
  }

  void _updateFormData() {
    final Map<String, dynamic> formData = {};
    
    for (final field in _fields) {
      if (field.type == 'group' && field.fields != null) {
        // Handle group fields
        field.fields!.forEach((subFieldName, subField) {
          final controller = _controllers[subField.name];
          if (controller != null) {
            String value = controller.text;
            
            // Apply formatting based on field type
            if (subField.name == 'ifscCode') {
              value = formatIFSC(value);
            } else if (subField.name == 'panNumber') {
              value = formatPAN(value);
            }
            
            formData[subField.name] = value;
          }
        });
      } else {
        // Handle regular fields
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
    }
    
    widget.onDataChanged(formData);
    
    // Check validation and notify parent
    _checkValidation();
  }

  void _checkValidation() {
    bool isValid = true;
    
    for (final field in _fields) {
      if (field.type == 'group' && field.fields != null) {
        // Check group fields
        field.fields!.forEach((subFieldName, subField) {
          if (subField.isRequired) {
            final controller = _controllers[subField.name];
            if (controller == null || controller.text.trim().isEmpty) {
              isValid = false;
            } else if (controller.text.trim().length < 3) {
              isValid = false;
            }
          }
        });
      } else {
        // Check regular fields
        if (field.isRequired) {
          final controller = _controllers[field.name];
          if (controller == null || controller.text.trim().isEmpty) {
            isValid = false;
          } else if (controller.text.trim().length < 3) {
            isValid = false;
          }
        }
      }
    }
    
    widget.onValidationChanged?.call(isValid);
  }

  bool _shouldShowField(AdditionalField field) {
    if (field.dependsOn == null) return true;
    
    // For nested fields, the dependsOn should reference the field name within the group
    final dependsOnController = _controllers[field.dependsOn];
    if (dependsOnController == null) return true;
    
    return dependsOnController.text.isNotEmpty;
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
        return Colors.pink;
      case 'favorite':
        return Colors.red;
      case 'account_balance':
        return Colors.green;
      case 'business':
        return Colors.blue;
      case 'code':
        return Colors.orange;
      case 'credit_card':
        return Colors.purple;
      case 'email':
        return Colors.blue;
      case 'phone':
        return Colors.green;
      case 'person':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String? Function(String?)? _getValidatorForField(AdditionalField field) {
    return (value) {
      if (field.isRequired && (value == null || value.trim().isEmpty)) {
        return 'This field is required';
      }
      
      if (value != null && value.isNotEmpty) {
        // Check minimum length for all text fields in additional details
        if (value.trim().length < 3) {
          return 'This field must be at least 3 characters long';
        }
        
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

  Widget _buildField(AdditionalField field) {
    if (!_shouldShowField(field)) {
      return const SizedBox.shrink();
    }

    if (field.type == 'group' && field.fields != null) {
      return _buildGroupField(field);
    } else {
      return _buildSingleField(field);
    }
  }

  Widget _buildGroupField(AdditionalField groupField) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group header
          Row(
            children: [
              Icon(
                _getIconForField(groupField.icon),
                color: _getIconColorForField(groupField.icon),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Text(
                      groupField.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    if (groupField.isRequired) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (groupField.description != null) ...[
            const SizedBox(height: 4),
            Text(
              groupField.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(height: 16),
          
          // Group fields - check dependencies for each subfield
          ...groupField.fields!.entries.map((entry) {
            final subField = entry.value;
            // Check if this subfield should be shown based on its dependencies
            if (!_shouldShowField(subField)) {
              return const SizedBox.shrink();
            }
            return _buildSingleField(subField, isInGroup: true);
          }),
        ],
      ),
    );
  }

  Widget _buildSingleField(AdditionalField field, {bool isInGroup = false}) {
    final controller = _controllers[field.name];
    if (controller == null) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(bottom: isInGroup ? 12 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Row(
            children: [
              if (!isInGroup) ...[
                Icon(
                  _getIconForField(field.icon),
                  color: _getIconColorForField(field.icon),
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Row(
                  children: [
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
              ),
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
                fillColor: Colors.white,
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
                setState(() {}); // Trigger rebuild for dependencies
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
                fillColor: Colors.white,
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
              onChanged: (value) {
                _updateFormData();
                setState(() {}); // Trigger rebuild for dependencies
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Form Container
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
                          'Additional Details',
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
                          ..._fields.map((field) => _buildField(field)),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'No additional fields configured',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 20),
                        
                        // Information Card
                        Container(
                          margin: const EdgeInsets.only(top: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.blue[600],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All fields marked with * are required.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue[700],
                                  ),
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
} 