import 'package:flutter/material.dart';
import 'package:hassanjewellers/Services/firebase_services/add_address.dart';
import 'package:hassanjewellers/Services/firebase_services/update_address.dart';

class AddressFormScreen extends StatefulWidget {
  final Map<String, dynamic>? addressData; // null for add, non-null for edit
  final String? addressId; // null for add, non-null for edit

  const AddressFormScreen({
    super.key,
    this.addressData,
    this.addressId,
  });

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _alternativeMobileController = TextEditingController();
  final _aptFloorDoorController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.addressData != null;
    
    if (_isEditMode && widget.addressData != null) {
      // Pre-fill the form with existing data
      _firstNameController.text = widget.addressData!['firstName'] ?? '';
      _lastNameController.text = widget.addressData!['lastName'] ?? '';
      _mobileController.text = widget.addressData!['mobileNumber'] ?? '';
      _alternativeMobileController.text = widget.addressData!['alternativeMobileNumber'] ?? '';
      _aptFloorDoorController.text = widget.addressData!['aptFloorDoorNumber'] ?? '';
      _streetNameController.text = widget.addressData!['streetName'] ?? '';
      _cityController.text = widget.addressData!['city'] ?? '';
      _stateController.text = widget.addressData!['state'] ?? '';
      _pincodeController.text = widget.addressData!['pincode'] ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _alternativeMobileController.dispose();
    _aptFloorDoorController.dispose();
    _streetNameController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  // Simple text field widget inspired by account_screen
  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool isRequired = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with icon
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              if (isRequired) ...[
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
          // Text field
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
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
                  color: iconColor,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Address' : 'Add Address'),
        foregroundColor: Colors.white,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E3A8A), // Deep Blue
                Color(0xFF3B82F6), // Bright Blue
                Color(0xFF1E40AF), // Dark Blue
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {}, // Optional: Add functionality if needed
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Form Container similar to account_screen
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // First Name
                        _buildSimpleTextField(
                          controller: _firstNameController,
                          label: 'First Name',
                          hint: 'Enter your first name',
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF1976D2),
                          backgroundColor: const Color(0xFFE3F2FD),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your first name';
                            }
                            return null;
                          },
                        ),

                        // Last Name
                        _buildSimpleTextField(
                          controller: _lastNameController,
                          label: 'Last Name',
                          hint: 'Enter your last name',
                          icon: Icons.person_outline,
                          iconColor: const Color(0xFF7B1FA2),
                          backgroundColor: const Color(0xFFF3E5F5),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your last name';
                            }
                            return null;
                          },
                        ),

                        // Apt/Floor/Door Number
                        _buildSimpleTextField(
                          controller: _aptFloorDoorController,
                          label: 'Apt/Floor/Door Number',
                          hint: 'Enter apartment, floor, or door number',
                          icon: Icons.home_outlined,
                          iconColor: const Color(0xFFF57C00),
                          backgroundColor: const Color(0xFFFFF3E0),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter apartment/floor/door number';
                            }
                            return null;
                          },
                        ),

                        // Street Name
                        _buildSimpleTextField(
                          controller: _streetNameController,
                          label: 'Street Name',
                          hint: 'Enter your street name',
                          icon: Icons.streetview_outlined,
                          iconColor: const Color(0xFF388E3C),
                          backgroundColor: const Color(0xFFE8F5E8),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your street name';
                            }
                            return null;
                          },
                        ),

                        // City
                        _buildSimpleTextField(
                          controller: _cityController,
                          label: 'City',
                          hint: 'Enter your city',
                          icon: Icons.location_city_outlined,
                          iconColor: const Color(0xFF0097A7),
                          backgroundColor: const Color(0xFFE1F5FE),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your city';
                            }
                            return null;
                          },
                        ),

                        // State
                        _buildSimpleTextField(
                          controller: _stateController,
                          label: 'State',
                          hint: 'Enter your state',
                          icon: Icons.map_outlined,
                          iconColor: const Color(0xFFD32F2F),
                          backgroundColor: const Color(0xFFFFEBEE),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your state';
                            }
                            return null;
                          },
                        ),

                        // Pincode
                        _buildSimpleTextField(
                          controller: _pincodeController,
                          label: 'Pincode',
                          hint: 'Enter your pincode',
                          icon: Icons.pin_drop_outlined,
                          iconColor: const Color(0xFF8E24AA),
                          backgroundColor: const Color(0xFFF3E5F5),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your pincode';
                            }
                            if (value.length != 6) {
                              return 'Pincode must be 6 digits';
                            }
                            return null;
                          },
                        ),

                        // Mobile Number
                        _buildSimpleTextField(
                          controller: _mobileController,
                          label: 'Mobile Number',
                          hint: 'Enter your mobile number',
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF2E7D32),
                          backgroundColor: const Color(0xFFE8F5E8),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your mobile number';
                            }
                            if (value.length != 10) {
                              return 'Mobile number must be 10 digits';
                            }
                            return null;
                          },
                        ),

                        // Alternative Mobile Number
                        _buildSimpleTextField(
                          controller: _alternativeMobileController,
                          label: 'Alternative Mobile Number',
                          hint: 'Enter alternative mobile number (optional)',
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF1565C0),
                          backgroundColor: const Color(0xFFE3F2FD),
                          keyboardType: TextInputType.phone,
                          isRequired: false,
                          validator: (value) {
                            if (value != null && value.trim().isNotEmpty) {
                              if (value.length != 10) {
                                return 'Mobile number must be 10 digits';
                              }
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Save Button similar to account_screen style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isEditMode ? Icons.update : Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isEditMode ? 'Update Address' : 'Save Address',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      
      final addressData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'aptFloorDoorNumber': _aptFloorDoorController.text.trim(),
        'streetName': _streetNameController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'pincode': _pincodeController.text.trim(),
        'mobileNumber': _mobileController.text.trim(),
        'alternativeMobileNumber': _alternativeMobileController.text.trim(),
      };
      
      String? result;
      
      if (_isEditMode && widget.addressId != null) {
        // Update existing address
        result = await updateUserAddress(widget.addressId!, addressData);
      } else {
        // Add new address
        result = await addAddressToUser(addressData);
      }
      
      setState(() {
        _isLoading = false;
      });
      
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode 
                ? 'Address updated successfully!' 
                : 'Address saved successfully!'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode 
                ? 'Failed to update address. Please try again.'
                : 'Failed to save address. Please try again.'),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }
} 