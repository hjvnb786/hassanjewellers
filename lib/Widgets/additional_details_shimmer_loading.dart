import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AdditionalDetailsShimmerLoading extends StatelessWidget {
  const AdditionalDetailsShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 24,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 16,
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Date fields row
            Row(
              children: [
                Expanded(
                  child: _buildFieldShimmer(
                    iconSize: 20,
                    labelWidth: 80,
                    fieldHeight: 56,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFieldShimmer(
                    iconSize: 20,
                    labelWidth: 100,
                    fieldHeight: 56,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Bank account fields
            _buildFieldShimmer(
              iconSize: 20,
              labelWidth: 120,
              fieldHeight: 56,
            ),
            const SizedBox(height: 16),
            
            _buildFieldShimmer(
              iconSize: 20,
              labelWidth: 140,
              fieldHeight: 56,
            ),
            const SizedBox(height: 16),
            
            // Bank branch and IFSC row
            Row(
              children: [
                Expanded(
                  child: _buildFieldShimmer(
                    iconSize: 20,
                    labelWidth: 80,
                    fieldHeight: 56,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFieldShimmer(
                    iconSize: 20,
                    labelWidth: 80,
                    fieldHeight: 56,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // PAN field
            _buildFieldShimmer(
              iconSize: 20,
              labelWidth: 80,
              fieldHeight: 56,
            ),
            const SizedBox(height: 20),
            
            // Information card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and title
                  Row(
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Features list
                  ...List.generate(4, (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        height: 16,
                        width: MediaQuery.of(context).size.width * (0.8 - index * 0.1),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldShimmer({
    required double iconSize,
    required double labelWidth,
    required double fieldHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with icon
        Row(
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(iconSize / 2),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 4),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Field
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: fieldHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
} 