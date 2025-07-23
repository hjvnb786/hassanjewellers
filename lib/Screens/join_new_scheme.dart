import 'package:flutter/material.dart';
import 'package:hassanjewellers/Widgets/user_details_form.dart';
import 'package:hassanjewellers/Widgets/scheme_details_form.dart';
import 'package:hassanjewellers/Widgets/additional_details_form.dart';
import 'package:hassanjewellers/Widgets/detail_summary.dart';
import 'package:hassanjewellers/Screens/payment.dart';

class JoinNewScheme extends StatefulWidget {
  const JoinNewScheme({super.key});

  @override
  State<JoinNewScheme> createState() => _JoinNewSchemeState();
}

class _JoinNewSchemeState extends State<JoinNewScheme> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};
  final PageController _pageController = PageController();

  final List<String> _stepTitles = [
    'User Details',
    'Scheme Details',
    'Additional Details',
    'Summary',
  ];

  final List<IconData> _stepIcons = [
    Icons.person,
    Icons.account_balance_wallet,
    Icons.add_circle_outline,
    Icons.summarize,
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateFormData(Map<String, dynamic> newData) {
    setState(() {
      _formData.addAll(newData);
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToStep(int step) {
    setState(() {
      _currentStep = step;
    });
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  bool _canProceedToNext() {
    switch (_currentStep) {
      case 0: // User Details
        return _formData['firstName']?.isNotEmpty == true &&
               _formData['lastName']?.isNotEmpty == true &&
               _formData['mobile']?.isNotEmpty == true &&
               _formData['email']?.isNotEmpty == true &&
               _formData['address']?.isNotEmpty == true;
      case 1: // Scheme Details
        return _formData['schemeName']?.isNotEmpty == true &&
               _formData['schemeAmount']?.isNotEmpty == true;
      case 2: // Additional Details (Optional)
        return true;
      case 3: // Summary
        return true;
      default:
        return false;
    }
  }

  void _onConfirm() {
    // Navigate to payment page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Payment(formData: _formData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join New Scheme'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Step Indicators
                Row(
                  children: List.generate(4, (index) {
                    final isActive = index == _currentStep;
                    final isCompleted = index < _currentStep;
                    
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? Colors.white
                                    : isActive
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                _stepIcons[index],
                                color: isCompleted || isActive
                                    ? Theme.of(context).primaryColor
                                    : Colors.white.withOpacity(0.5),
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _stepTitles[index],
                              style: TextStyle(
                                color: isCompleted || isActive
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // Progress Bar
                LinearProgressIndicator(
                  value: (_currentStep + 1) / 4,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ],
            ),
          ),
          
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: User Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: UserDetailsForm(
                    formData: _formData,
                    onDataChanged: _updateFormData,
                  ),
                ),
                
                // Step 2: Scheme Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: SchemeDetailsForm(
                    formData: _formData,
                    onDataChanged: _updateFormData,
                  ),
                ),
                
                // Step 3: Additional Details
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: AdditionalDetailsForm(
                    formData: _formData,
                    onDataChanged: _updateFormData,
                  ),
                ),
                
                // Step 4: Summary
                SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: DetailSummary(
                    formData: _formData,
                    onConfirm: _onConfirm,
                  ),
                ),
              ],
            ),
          ),
          
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _canProceedToNext() ? _nextStep : null,
                    icon: Icon(_currentStep == 3 ? Icons.check : Icons.arrow_forward),
                    label: Text(_currentStep == 3 ? 'Complete' : 'Next'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
} 