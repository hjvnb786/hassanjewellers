import 'package:flutter/material.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_email.dart';
import 'package:hassanjewellers/Helpers/join_scheme_helpers/validate_mobile.dart';
import 'package:hassanjewellers/Services/firebase_services/get_user_addresses.dart';
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
  String? _selectedAddressId;
  String _selectedAddressText = '';

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
    _selectedAddressId = widget.formData['selectedAddressId'];
    _selectedAddressText = widget.formData['address'] ?? '';
  }

  Future<void> _loadUserAddresses() async {
    setState(() {
      _isLoadingAddresses = true;
    });
    
    final addresses = await getUserAddresses();
    
    if (mounted) {
      setState(() {
        _userAddresses = addresses;
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
      'selectedAddressId': _selectedAddressId,
      'address': _selectedAddressText,
    });
  }

  void _selectAddress(String? addressId) {
    if (addressId == null) {
      setState(() {
        _selectedAddressId = null;
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
        _selectedAddressId = addressId;
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

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'User Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          
          // First Name
          TextFormField(
            controller: _firstNameController,
            decoration: const InputDecoration(
              labelText: 'First Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'First name is required';
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Last Name
          TextFormField(
            controller: _lastNameController,
            decoration: const InputDecoration(
              labelText: 'Last Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Mobile Number
          TextFormField(
            controller: _mobileController,
            decoration: const InputDecoration(
              labelText: 'Mobile Number *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
              prefixText: '+91 ',
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Mobile number is required';
              }
              if (!validateMobile(value)) {
                return 'Please enter a valid mobile number';
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Email Address
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email address is required';
              }
              if (!validateEmail(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
            onChanged: (value) => _updateFormData(),
          ),
          const SizedBox(height: 16),
          
          // Delivery Address Selection
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Address *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingAddresses)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 12),
                      Text('Loading addresses...'),
                    ],
                  ),
                )
              else if (_userAddresses.isEmpty)
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                              else
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedAddressId,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        hint: const Text('Select a delivery address'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Select a delivery address'),
                          ),
                          ..._userAddresses.map((address) {
                            final addressText = '${address['firstName']} ${address['lastName']} - ${address['city']}, ${address['state']}';
                            return DropdownMenuItem<String>(
                              value: address['id'],
                              child: Text(addressText),
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
                    ),
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
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_selectedAddressText.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Address:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedAddressText,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
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