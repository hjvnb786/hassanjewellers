import 'package:flutter/material.dart';
import 'package:hassanjewellers/Screens/scheme_progress_screen.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';

class SchemeItem extends StatelessWidget {
  final String id;
  final String name;
  final String amount;
  final List<dynamic> progress;
  final Map<String, dynamic> schemeDetails;

  const SchemeItem({
    super.key,
    required this.id,
    required this.name,
    required this.amount,
    required this.progress,
    required this.schemeDetails,
  });

  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SchemeProgressScreen(
        id: id,
        progress: progress,
        amount: amount,
        name: name,
        schemeDetails: schemeDetails,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  // Get color based on progress
  Color getProgressColor(double progressPercentage) {
    return AppColors.primary; // Use app's primary color
  }

  // Get icon based on progress
  IconData getProgressIcon(double progressPercentage) {
    if (progressPercentage == 1) {
      return Icons.check_circle;
    } else if (progressPercentage >= 0.7) {
      return Icons.trending_up;
    } else if (progressPercentage >= 0.4) {
      return Icons.schedule;
    } else {
      return Icons.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    int progressNumber = 0;
    for (var element in progress) {
      if (element["paid"] == true) {
        progressNumber++;
      }
    }

    // Use actual progress length instead of hardcoded 12
    final progressLength = progress.length;
    final progressPercentage = progressNumber / progressLength;
    final remainingAmount = (progressLength - progressNumber) * int.parse(amount.replaceAll(RegExp(r'[^0-9]'), ''));
    final progressColor = getProgressColor(progressPercentage);
    final progressIcon = getProgressIcon(progressPercentage);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: progressColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(createRoute());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      progressIcon,
                      color: progressColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Scheme Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          amount,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Progress Percentage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(progressPercentage * 100).toInt()}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Clickable indicator
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercentage,
                  minHeight: 8,
                  backgroundColor: AppColors.progressBackground,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 16),
              
              // Progress Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: progressColor,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$progressNumber of $progressLength installments paid',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '₹$remainingAmount remaining',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: progressColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
