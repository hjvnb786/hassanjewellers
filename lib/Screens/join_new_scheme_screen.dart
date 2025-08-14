import 'package:flutter/material.dart';
import 'package:hassanjewellers/Widgets/join_scheme_widgets/user_details_form.dart';
import 'package:hassanjewellers/Widgets/join_scheme_widgets/scheme_details_form.dart';
import 'package:hassanjewellers/Widgets/join_scheme_widgets/additional_details_form.dart';
import 'package:hassanjewellers/Widgets/join_scheme_widgets/detail_summary.dart';
import 'package:hassanjewellers/Screens/payment_screen.dart';

class JoinNewSchemeScreen extends StatefulWidget {
  const JoinNewSchemeScreen({super.key});

  @override
  State<JoinNewSchemeScreen> createState() => _JoinNewSchemeScreenState();
}

class _JoinNewSchemeScreenState extends State<JoinNewSchemeScreen> {
  int _currentStep = 0;
  final Map<String, dynamic> _formData = {};
  final PageController _pageController = PageController();
  final ScrollController _progressScrollController = ScrollController();
  bool _additionalDetailsValid = true; // Track Additional Details validation

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

  // Define unique light-toned colors for each step
  Color getStepColor(int stepIndex) {
    switch (stepIndex) {
      case 0: return const Color(0xFF1976D2); // Blue
      case 1: return const Color(0xFF7B1FA2); // Purple
      case 2: return const Color(0xFFF57C00); // Orange
      case 3: return const Color(0xFF388E3C); // Green
      default: return const Color(0xFF1976D2);
    }
  }
  
  Color getStepBackgroundColor(int stepIndex) {
    switch (stepIndex) {
      case 0: return const Color(0xFFE3F2FD); // Light Blue
      case 1: return const Color(0xFFF3E5F5); // Light Purple
      case 2: return const Color(0xFFFFF3E0); // Light Orange
      case 3: return const Color(0xFFE8F5E8); // Light Green
      default: return const Color(0xFFE3F2FD);
    }
  }

  Widget _buildProgressIndicator() {
    return Padding(
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
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
                                              // Step Indicators - Made scrollable
                                Container(
                                                child: SingleChildScrollView(
                                  controller: _progressScrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                    child: Row(
                    children: List.generate(4, (index) {
                      final isActive = index == _currentStep;
                      final isCompleted = index < _currentStep;
                      
                      return Row(
                        children: [
                          Container(
                            width: 100, // Increased width for each step
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isCompleted || isActive
                                        ? getStepBackgroundColor(index)
                                        : Colors.transparent,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isCompleted || isActive
                                          ? getStepColor(index)
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _stepIcons[index],
                                    color: isCompleted || isActive
                                        ? getStepColor(index)
                                        : Colors.grey[400],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _stepTitles[index],
                                  style: TextStyle(
                                    color: isCompleted || isActive
                                        ? getStepColor(index)
                                        : Colors.grey[600],
                                    fontSize: 12,
                                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                          // Add connecting line between steps (except after the last step)
                          if (index < 3)
                            Container(
                              width: 20,
                              height: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? getStepColor(index + 1) 
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      getStepColor(_currentStep),
                    ),
                    minHeight: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressScrollController.dispose();
    super.dispose();
  }

  void _updateFormData(Map<String, dynamic> newData) {
    setState(() {
      _formData.addAll(newData);
    });
  }

  void _onAdditionalDetailsValidationChanged(bool isValid) {
    setState(() {
      _additionalDetailsValid = isValid;
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
      ).then((_) {
        _scrollToCurrentStep();
      });
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
      ).then((_) {
        _scrollToCurrentStep();
      });
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
    ).then((_) {
      _scrollToCurrentStep();
    });
  }

  void _scrollToCurrentStep() {
    // Add a small delay to ensure the widget is built
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_progressScrollController.hasClients) {
        // Calculate the position to scroll to center the current step
        final double stepWidth = 100.0; // Width of each step
        final double stepMargin = 4.0; // Margin between steps
        final double lineWidth = 20.0; // Width of connecting line
        final double totalStepWidth = stepWidth + stepMargin + lineWidth;
        
        // Calculate position to center the current step
        final double scrollPosition = _currentStep * totalStepWidth;
        
        _progressScrollController.animateTo(
          scrollPosition,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
      case 2: // Additional Details
        return _additionalDetailsValid;
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
        builder: (context) => PaymentScreen(formData: _formData, operation: 'add'),
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
          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // Step 1: User Details
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),
                      UserDetailsForm(
                        formData: _formData,
                        onDataChanged: _updateFormData,
                      ),
                      // Navigation Buttons
                      Container(
                        margin: const EdgeInsets.all(16),
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
                      ),
                    ],
                  ),
                ),
                
                // Step 2: Scheme Details
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),
                      SchemeDetailsForm(
                        formData: _formData,
                        onDataChanged: _updateFormData,
                      ),
                      // Navigation Buttons
                      Container(
                        margin: const EdgeInsets.all(16),
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
                      ),
                    ],
                  ),
                ),
                
                // Step 3: Additional Details
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),
                      AdditionalDetailsForm(
                        formData: _formData,
                        onDataChanged: _updateFormData,
                        onValidationChanged: _onAdditionalDetailsValidationChanged,
                      ),
                      // Navigation Buttons
                      Container(
                        margin: const EdgeInsets.all(16),
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
                      ),
                    ],
                  ),
                ),
                
                // Step 4: Summary
                SingleChildScrollView(
                  child: Column(
                    children: [
                      // Progress Indicator
                      _buildProgressIndicator(),
                      DetailSummary(
                        formData: _formData,
                        onConfirm: _onConfirm,
                      ),
                      // Navigation Buttons
                      Container(
                        margin: const EdgeInsets.all(16),
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
                      ),
                    ],
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