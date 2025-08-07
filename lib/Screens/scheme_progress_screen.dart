import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/payment_screen.dart';
import 'package:hassanjewellers/Helpers/utils.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SchemeProgressScreen extends StatefulWidget {
  final String id;
  final List<dynamic> progress;
  final String amount;
  final String name;
  final Map<String, dynamic> schemeDetails;

  const SchemeProgressScreen({
    super.key,
    required this.progress,
    required this.id,
    required this.amount,
    required this.name,
    required this.schemeDetails,
  });

  @override
  State<SchemeProgressScreen> createState() => _SchemeProgressScreenState();
}

class _SchemeProgressScreenState extends State<SchemeProgressScreen> {
  int currentStep = 0;
  late List<Map<String, dynamic>> progressList;
  bool enableButton = true;
  final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final dateFormat = DateFormat('dd MMM yyyy');
  
  // Add state for dropdown sections
  bool isPersonalDetailsExpanded = false;
  bool isSchemeDetailsExpanded = false;
  bool isAdditionalDetailsExpanded = false;

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return dateFormat.format(date.toDate());
    }
    return date.toString();
  }

  @override
  void initState() {
    super.initState();
    progressList = getProgressList(widget.progress);
  }

  void handlePay() {
    // Create formData from scheme details for consistent payment processing
    Map<String, dynamic> formData = {
      'firstName': widget.name.split(' ').first,
      'lastName': widget.name.split(' ').length > 1 ? widget.name.split(' ').last : '',
      'schemeAmount': widget.amount,
      'schemeName': widget.schemeDetails['name'] ?? widget.name,
      'schemeDescription': widget.schemeDetails['description'] ?? '',
      'schemeDuration': widget.schemeDetails['duration'] ?? 12,
      'schemeId': widget.id, // Add the Firestore document ID
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          formData: formData,
          operation: 'update',
        ),
      ),
    );
  }

  List<String> installmentLabels = [
    "First Installment",
    "Second Installment",
    "Third Installment",
    "Fourth Installment",
    "Fifth Installment",
    "Sixth Installment",
    "Seventh Installment",
    "Eighth Installment",
    "Ninth Installment",
    "Tenth Installment",
    "Eleventh Installment",
    "Twelfth Installment",
  ];

  @override
  Widget build(BuildContext context) {
    for (var i = 0; i < progressList.length; i++) {
      if (progressList[i]['paid'] == false) {
        progressList[i]['payButton'] = true;
        break;
      }
    }

    int paidCount = progressList.where((item) => item['paid'] == true).length;
    double progressPercentage = paidCount / progressList.length;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            forceElevated: false,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.transparent, width: 0),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 2.0,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currencyFormat.format(int.parse(widget.amount.replaceAll(RegExp(r'[^0-9]'), '')))} per month',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Personal Details Section - Consistent Design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              isPersonalDetailsExpanded = !isPersonalDetailsExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.person, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Personal Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isPersonalDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        if (isPersonalDetailsExpanded)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildPersonalDetails(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Scheme Details Section - Consistent Design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              isSchemeDetailsExpanded = !isSchemeDetailsExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Scheme Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSchemeDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        if (isSchemeDetailsExpanded)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildSchemeDetails(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Additional Details Section - Consistent Design
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Header
                        InkWell(
                          onTap: () {
                            setState(() {
                              isAdditionalDetailsExpanded = !isAdditionalDetailsExpanded;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Additional Details',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isAdditionalDetailsExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Content
                        if (isAdditionalDetailsExpanded)
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildAdditionalDetails(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowLight,
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${(progressPercentage * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progressPercentage,
                            minHeight: 8,
                            backgroundColor: AppColors.progressBackground,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.progressValue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$paidCount of ${progressList.length} installments paid',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Installment History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: progressList.length,
                    itemBuilder: (context, index) {
                      final item = progressList[index];
                      final isPaid = item['paid'] == true;
                      final isNextToPay = item['payButton'] == true;

                                            return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPaid 
                                ? AppColors.successLight.withOpacity(0.2)
                                : isNextToPay 
                                    ? AppColors.primary.withOpacity(0.15)
                                    : Colors.grey.withOpacity(0.1),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Header with status and action
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  // Simple status indicator
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? AppColors.successLight.withOpacity(0.1)
                                          : isNextToPay
                                              ? AppColors.primary.withOpacity(0.1)
                                              : Colors.grey.withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isPaid
                                            ? AppColors.successLight.withOpacity(0.3)
                                            : isNextToPay
                                                ? AppColors.primary.withOpacity(0.3)
                                                : Colors.grey.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: Icon(
                                      isPaid
                                          ? Icons.check_circle_outline
                                          : isNextToPay
                                              ? Icons.payment_outlined
                                              : Icons.schedule_outlined,
                                      color: isPaid
                                          ? AppColors.successLight
                                          : isNextToPay
                                              ? AppColors.primary
                                              : Colors.grey,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Installment info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['label'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: isPaid 
                                                ? AppColors.text 
                                                : isNextToPay 
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isPaid 
                                              ? 'Payment Completed'
                                              : isNextToPay 
                                                  ? 'Ready to Pay'
                                                  : 'Pending',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isPaid 
                                                ? AppColors.successLight
                                                : isNextToPay 
                                                    ? AppColors.primary
                                                    : AppColors.textSecondary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Simple action button
                                  if (!isPaid && isNextToPay)
                                    ElevatedButton(
                                      onPressed: handlePay,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 10,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                      child: const Text(
                                        'Pay Now',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Simple payment details for paid installments
                            if (isPaid) ...[
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.successLight.withOpacity(0.03),
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  border: Border(
                                    top: BorderSide(
                                      color: AppColors.successLight.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.receipt_outlined,
                                            size: 16,
                                            color: AppColors.successLight,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Payment Information',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.successLight,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Paid on ${_formatDate(item["date"])}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.successLight,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              'SUCCESS',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Payment response details
                                      if (item["paymentResponse"] != null) ...[
                                        const SizedBox(height: 12),
                                        _buildPaymentDetails(item["paymentResponse"]),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails(Map<String, dynamic> paymentResponse) {
    return ExpansionTile(
      title: Row(
        children: [
          Icon(
            Icons.payment,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Payment Details',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: paymentResponse.entries.map((entry) {
              String key = entry.key;
              dynamic value = entry.value;
              
              // Convert key to display format (e.g., "reference_no" -> "Reference No")
              String displayKey = key.replaceAllMapped(
                RegExp(r'([A-Z])'),
                (match) => ' ${match.group(1)}',
              ).replaceAll('_', ' ').trim();
              displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);
              
              return _buildPaymentDetailRow(displayKey, value.toString());
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalDetails() {
    final personalDetails = widget.schemeDetails['personalDetails'] as Map<String, dynamic>? ?? {};
    
    if (personalDetails.isEmpty) {
      return Text(
        'No personal details available',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: personalDetails.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        // Skip additionalDetails as it's handled separately
        if (key == 'additionalDetails') {
          return const SizedBox.shrink();
        }
        
        // Convert key to display format (e.g., "firstName" -> "First Name")
        String displayKey = key.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim();
        displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);
        
        return _buildDetailRow(displayKey, value.toString());
      }).toList(),
    );
  }

  Widget _buildSchemeDetails() {
    final schemeDetails = widget.schemeDetails['schemeDetails'] as Map<String, dynamic>? ?? {};
    
    if (schemeDetails.isEmpty) {
      return Text(
        'No scheme details available',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: schemeDetails.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        // Convert key to display format (e.g., "schemeName" -> "Scheme Name")
        String displayKey = key.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim();
        displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);
        
        // Special formatting for certain fields
        String displayValue = value.toString();
        if (key == 'schemeDuration') {
          displayValue = '$value months';
        }
        
        return _buildDetailRow(displayKey, displayValue);
      }).toList(),
    );
  }

  Widget _buildAdditionalDetails() {
    final additionalDetails = widget.schemeDetails['personalDetails']?['additionalDetails'] as Map<String, dynamic>? ?? {};
    
    if (additionalDetails.isEmpty) {
      return Text(
        'No additional details available',
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: additionalDetails.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;
        
        // Convert key to display format (e.g., "guardianName" -> "Guardian Name")
        String displayKey = key.replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(1)}',
        ).trim();
        displayKey = displayKey[0].toUpperCase() + displayKey.substring(1);
        
        return _buildDetailRow(displayKey, value.toString());
      }).toList(),
    );
  }
}
