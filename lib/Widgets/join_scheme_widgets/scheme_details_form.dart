import 'package:flutter/material.dart';
import '../../Services/firebase_services/getPlans.dart';
import '../scheme_details_shimmer_loading.dart';

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
  String? _schemeDescription;
  int? _schemeDuration;
  
  List<Plan> _plans = [];
  List<String> _availableAmounts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
    _fetchPlans();
  }

  void _loadExistingData() {
    _selectedSchemeName = widget.formData['schemeName'];
    _selectedSchemeAmount = widget.formData['schemeAmount'];
    _schemeDescription = widget.formData['schemeDescription'];
    _schemeDuration = widget.formData['schemeDuration'];
  }

  Future<void> _fetchPlans() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Fetching plans in form...');
      final plans = await getPlans();
      print('Received ${plans.length} plans in form');
      
      setState(() {
        _plans = plans;
        _isLoading = false;
      });

      // If we have existing data, try to restore the selected scheme
      if (_selectedSchemeName != null) {
        print('Restoring selected scheme: $_selectedSchemeName');
        _onSchemeNameChanged(_selectedSchemeName);
      }
    } catch (e) {
      print('Error in _fetchPlans: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load schemes. Please try again.';
      });
    }
  }

  void _onSchemeNameChanged(String? newValue) {
    print('Scheme name changed to: $newValue');
    setState(() {
      _selectedSchemeName = newValue;
      _selectedSchemeAmount = null; // Reset amount when scheme changes
      _availableAmounts = [];
      _schemeDescription = null;
      _schemeDuration = null;

      if (newValue != null) {
        // Find the selected plan
        final selectedPlan = _plans.firstWhere(
          (plan) => plan.name == newValue,
          orElse: () => Plan(name: '', description: '', duration: 0, monthlyAmount: []),
        );

        print('Selected plan: ${selectedPlan.name}');
        print('Available amounts: ${selectedPlan.monthlyAmount}');

        if (selectedPlan.name.isNotEmpty) {
          _schemeDescription = selectedPlan.description;
          _schemeDuration = selectedPlan.duration;
          _availableAmounts = selectedPlan.monthlyAmount
              .map((amount) => '₹${amount.toStringAsFixed(0)}')
              .toList();
          
          print('Updated description: $_schemeDescription');
          print('Updated duration: $_schemeDuration');
          print('Updated available amounts: $_availableAmounts');
        }
      }
    });
    _updateFormData();
  }

  void _onAmountChanged(String? newValue) {
    setState(() {
      _selectedSchemeAmount = newValue;
    });
    _updateFormData();
  }

  void _updateFormData() {
    widget.onDataChanged({
      'schemeName': _selectedSchemeName,
      'schemeAmount': _selectedSchemeAmount,
      'schemeDescription': _schemeDescription,
      'schemeDuration': _schemeDuration,
    });
  }

  // Simple dropdown field widget matching user details form design
  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
    required Color iconColor,
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
          // Dropdown field
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Select $label',
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
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
            validator: validator,
            onChanged: onChanged,
            dropdownColor: Colors.white,
            icon: const SizedBox.shrink(), // Hide default icon
            menuMaxHeight: 200,
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
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
            // Form Container similar to user_details_form
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
                        const SchemeDetailsShimmerLoading()
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
                                onPressed: _fetchPlans,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        // Scheme Name Dropdown
                        _buildSimpleDropdown(
                          label: 'Scheme Name',
                          value: _selectedSchemeName,
                          items: _plans.map((plan) => plan.name).toList(),
                          onChanged: _onSchemeNameChanged,
                          icon: Icons.account_balance_wallet,
                          iconColor: const Color(0xFF1976D2),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select a scheme';
                            }
                            return null;
                          },
                        ),
                        
                        // Scheme Amount Dropdown
                        _buildSimpleDropdown(
                          label: 'Scheme Amount',
                          value: _selectedSchemeAmount,
                          items: _availableAmounts,
                          onChanged: _onAmountChanged,
                          icon: Icons.attach_money,
                          iconColor: const Color(0xFFF57C00),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an amount';
                            }
                            return null;
                          },
                        ),
                        
                        // Scheme Information Card
                        if (_schemeDescription != null || _schemeDuration != null)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF1976D2).withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: const Color(0xFF1976D2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Scheme Information',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1976D2),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                if (_schemeDescription != null) ...[
                                  Text(
                                    'Description:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _schemeDescription!,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                if (_schemeDuration != null) ...[
                                  Text(
                                    'Duration:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_schemeDuration} months',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      height: 1.5,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                                Text(
                                  '• Monthly installment payments\n'
                                  '• Flexible payment options\n'
                                  '• Secure investment in precious metals\n'
                                  '• Professional jewelry consultation\n'
                                  '• Delivery at scheme completion',
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
} 