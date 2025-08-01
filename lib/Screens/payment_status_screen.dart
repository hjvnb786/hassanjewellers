import 'package:flutter/material.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';
import 'package:hassanjewellers/Screens/home_screen.dart';

class PaymentStatusScreen extends StatelessWidget {
  final bool isSuccess;
  final String message;
  final String? referenceNo;
  final Map<String, dynamic>? paymentResponse;

  const PaymentStatusScreen({
    Key? key,
    required this.isSuccess,
    required this.message,
    this.referenceNo,
    this.paymentResponse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              // Main Card
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Main content
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 30), // Space for overlapping icon
                              
                              // Header
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      isSuccess ? "Payment Success!" : "Payment Failed!",
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      message,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              const Divider(color: Colors.grey, height: 1),
                              const SizedBox(height: 24),
                              
                              // Payment Details Grid
                              if (paymentResponse != null) ...[
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey[300]!,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      children: [
                                        // Header for the grid
                                        Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[50],
                                            borderRadius: const BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.receipt_long,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Payment Details",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const Spacer(),
                                              Icon(
                                                Icons.swipe_up,
                                                size: 16,
                                                color: Colors.grey[500],
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Scrollable grid
                                        Expanded(
                                          child: ListView.builder(
                                            padding: const EdgeInsets.all(16),
                                            itemCount: paymentResponse!.length,
                                            itemBuilder: (context, index) {
                                              final entry = paymentResponse!.entries.elementAt(index);
                                              final key = entry.key;
                                              final value = entry.value;
                                              
                                              if (value == null) return const SizedBox.shrink();
                                              
                                              return Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 8),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        _formatFieldName(key),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey[600],
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    Expanded(
                                                      flex: 3,
                                                      child: _buildValueWidget(key, value),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                              
                              const SizedBox(height: 24),
                              
                              // Back to Home Button
                              Center(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      "Back to Home",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Perforated bottom edge
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: CustomPaint(
                              painter: PerforatedEdgePainter(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Success Icon (positioned above the card)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFieldName(String key) {
    return key.replaceAll('_', ' ').split(' ').map((word) => 
      word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : word
    ).join(' ');
  }

  Widget _buildValueWidget(String key, dynamic value) {
    String displayValue = value.toString();
    
    // Special formatting for specific fields
    if (key == 'amount' || key == 'schemeAmount') {
      // Remove any existing currency symbols and add ₹
      displayValue = displayValue.replaceAll('₹', '').replaceAll(',', '');
      displayValue = '₹$displayValue';
    } else if (key == 'status' && displayValue.toLowerCase() == 'success') {
      return Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 10,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            displayValue,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }
    
    return Text(
      displayValue,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class PerforatedEdgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[50]!
      ..style = PaintingStyle.fill;

    const double holeRadius = 3;
    const double spacing = 20;
    
    for (double x = spacing; x < size.width; x += spacing) {
      canvas.drawCircle(
        Offset(x, size.height / 2),
        holeRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 