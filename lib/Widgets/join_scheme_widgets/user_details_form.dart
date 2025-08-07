import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_email.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_mobile.dart';
import 'package:hassanjewellers/Services/firebase_services/get_user_data.dart';
import 'package:hassanjewellers/Screens/address_form_screen.dart';

class UserDetailsForm extends StatefulWidget {
  final Map<String, dynamic> formData;
  final Function(Map<String, dynamic>) onDataChanged;

  const UserDetailsForm({
    super.key,
    required this.formData,
    required this.onDataChanged,
  });

  @override
  State<UserDetailsForm> createState() => _UserDetailsFormState();
}

class _UserDetailsFormState extends State<UserDetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  
  List<Map<String, dynamic>> _userAddresses = [];
  bool _isLoadingAddresses = true;
  String _selectedAddressText = '';
  String? _selectedAddressIdForDropdown; // Temporary ID for dropdown only

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _loadUserAddresses();
  }

  void _loadExistingData() {
    _firstNameController.text = widget.formData['firstName'] ?? '';
    _lastNameController.text = widget.formData['lastName'] ?? '';
    _mobileController.text = widget.formData['mobile'] ?? '';
    _emailController.text = widget.formData['email'] ?? '';
    _selectedAddressText = widget.formData['address'] ?? '';
    
    // Find the address ID that matches the current address text
    if (_selectedAddressText.isNotEmpty) {
      for (final address in _userAddresses) {
        final addressText = '${address['firstName']} ${address['lastName']}, ${address['aptFloorDoorNumber']}, ${address['streetName']}, ${address['city']}, ${address['state']} - ${address['pincode']}';
        if (addressText == _selectedAddressText) {
          _selectedAddressIdForDropdown = address['id'];
          break;
        }
      }
    }
  }

  Future<void> _loadUserAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });
    
    final userData = await getUserData();
    
    if (mounted && userData != null) {
      // Extract addresses from user data
      final addresses = userData['addresses'] as List<dynamic>?;
      final addressList = addresses?.map((address) => Map<String, dynamic>.from(address)).toList() ?? [];
      
      setState(() {
        _userAddresses = addressList;
        _isLoadingAddresses = false;
      });
      
      // After loading addresses, try to find the matching address ID
      if (_selectedAddressText.isNotEmpty) {
        for (final address in addressList) {
          final addressText = '${address['firstName']} ${address['lastName']}, ${address['aptFloorDoorNumber']}, ${address['streetName']}, ${address['city']}, ${address['state']} - ${address['pincode']}';
          if (addressText == _selectedAddressText) {
            _selectedAddressIdForDropdown = address['id'];
            break;
          }
        }
      }
    } else if (mounted) {
      setState(() {
        _isLoadingAddresses = false;
      });
    }
  }

  void _updateFormData() {
    widget.onDataChanged({
      'firstName': _firstNameController.text,
      'lastName': _lastNameController.text,
      'mobile': _mobileController.text,
      'email': _emailController.text,
      'address': _selectedAddressText,
    });
  }

  void _selectAddress(String? addressId) {
    if (addressId == null) {
      setState(() {
        _selectedAddressIdForDropdown = null;
        _selectedAddressText = '';
      });
      _updateFormData();
      return;
    }

    final selectedAddress = _userAddresses.firstWhere(
      (address) => address['id'] == addressId,
      orElse: () => {},
    );

    if (selectedAddress.isNotEmpty) {
      setState(() {
        _selectedAddressIdForDropdown = addressId;
        _selectedAddressText = '${selectedAddress['firstName']} ${selectedAddress['lastName']}, ${selectedAddress['aptFloorDoorNumber']}, ${selectedAddress['streetName']}, ${selectedAddress['city']}, ${selectedAddress['state']} - ${selectedAddress['pincode']}';
      });
      _updateFormData();
    }
  }

  Future<void> _addNewAddress() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddressFormScreen(),
      ),
    );
    // Refresh the address list after adding a new address
    await _loadUserAddresses();
  }

  // Simple text field widget inspired by address_form_screen
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
    String? prefixText,
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
              prefixText: prefixText,
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
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red[500]!, width: 2),
              ),
            ),
            onChanged: (value) => _updateFormData(),
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
            // Form Container similar to address_form_screen
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

                      // Mobile Number
                      _buildSimpleTextField(
                        controller: _mobileController,
                        label: 'Mobile Number',
                        hint: 'Enter your mobile number',
                        icon: Icons.phone_outlined,
                        iconColor: const Color(0xFFF57C00),
                        backgroundColor: const Color(0xFFFFF3E0),
                        keyboardType: TextInputType.phone,
                        prefixText: '+91 ',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (!validateMobile(value)) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),

                      // Email Address
                      _buildSimpleTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hint: 'Enter your email address',
                        icon: Icons.email_outlined,
                        iconColor: const Color(0xFF388E3C),
                        backgroundColor: const Color(0xFFE8F5E8),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!validateEmail(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      // Delivery Address Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                color: const Color(0xFF1976D2),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Delivery Address',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
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
                          ),
                          const SizedBox(height: 8),

                          if (_isLoadingAddresses)
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                border: Border.all(color: Colors.grey[200]!),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Loading addresses...',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_userAddresses.isEmpty)
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[50],
                                    border: Border.all(color: Colors.orange[200]!),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.orange[600], size: 20),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No addresses found. Add a new address to continue.',
                                          style: TextStyle(color: Colors.orange[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: _addNewAddress,
                                    icon: const Icon(Icons.add_location),
                                    label: const Text('Add New Address'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: _selectedAddressIdForDropdown, // Use the temporary ID
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    hintText: 'Choose a delivery address',
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
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: const Color(0xFF1976D2),
                                        width: 2,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.grey[300]!),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red[300]!),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(color: Colors.red[500]!, width: 2),
                                    ),
                                    suffixIcon: Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      child: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Colors.grey[600],
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  icon: const SizedBox.shrink(), // Hide default icon
                                  menuMaxHeight: 200,
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(16),
                                  items: [
                                    DropdownMenuItem<String>(
                                      value: null,
                                      child: Text(
                                        'Select a delivery address',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    ..._userAddresses.map((address) {
                                      final addressText = '${address['firstName']} ${address['lastName']}, ${address['aptFloorDoorNumber']}, ${address['streetName']}, ${address['city']}, ${address['state']} - ${address['pincode']}';
                                      return DropdownMenuItem<String>(
                                        value: address['id'],
                                        child: Text(
                                          addressText,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                  onChanged: (value) {
                                    _selectAddress(value);
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select a delivery address';
                                    }
                                    return null;
                                  },
                                ),
                                
                                if (_selectedAddressText.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      border: Border.all(color: Colors.green[200]!),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Selected Address:',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _selectedAddressText,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: _addNewAddress,
                                    icon: const Icon(Icons.add_location),
                                    label: const Text('Add New Address'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Theme.of(context).primaryColor,
                                      side: BorderSide(color: Theme.of(context).primaryColor),
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    super.dispose();
  }
} 