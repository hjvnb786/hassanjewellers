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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          id: widget.id,
          amount: widget.amount,
          name: widget.name, operation: 'update',
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
            expandedHeight: 200.0,
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
                    radius: 0.8,
                    colors: [
                      AppColors.primaryLight, // Bright Blue from app colors
                      AppColors.primary, // Royal Blue from app colors
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Scheme Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailRow('Guardian Name', (widget.schemeDetails['guardianName'] ?? 'N/A').toString()),
                        _buildDetailRow('Occupation', (widget.schemeDetails['occupation'] ?? 'N/A').toString()),
                        _buildDetailRow('Nominee Name', (widget.schemeDetails['nomineeName'] ?? 'N/A').toString()),
                        _buildDetailRow('Nominee Relation', (widget.schemeDetails['nomineeRelation'] ?? 'N/A').toString()),
                        _buildDetailRow('Address', (widget.schemeDetails['address'] ?? 'N/A').toString()),
                        _buildDetailRow('Age', (widget.schemeDetails['age'] ?? 'N/A').toString()),
                        _buildDetailRow('Start Date', _formatDate(widget.schemeDetails['date'])),
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
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isPaid
                                      ? AppColors.successLight
                                      : isNextToPay
                                          ? AppColors.primaryLight
                                          : AppColors.progressBackground,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isPaid
                                      ? Icons.check_circle
                                      : isNextToPay
                                          ? Icons.pending_actions
                                          : Icons.schedule,
                                  color: isPaid
                                      ? Colors.white
                                      : isNextToPay
                                          ? AppColors.primary
                                          : AppColors.iconSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'],
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    if (isPaid) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        'Paid on ${_formatDate(item["date"])}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Reference ID: ${item["referenceId"]}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (!isPaid && isNextToPay)
                                ElevatedButton(
                                  onPressed: handlePay,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonPrimary,
                                    foregroundColor: AppColors.buttonPrimaryText,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text('Pay Now'),
                                ),
                            ],
                          ),
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
}
