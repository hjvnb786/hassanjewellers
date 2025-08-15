import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';
import 'package:hassanjewellers/Services/firebase_services/check_maintenance.dart';
import 'package:hassanjewellers/Services/firebase_services/get_more_options.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  Map<String, dynamic>? _moreOptionsData;

  @override
  void initState() {
    super.initState();
    _loadMoreOptionsData();
  }

  Future<void> _loadMoreOptionsData() async {
    try {
      final moreOptionsData = await getMoreOptions();
      if (mounted) {
        setState(() {
          _moreOptionsData = moreOptionsData;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _showContactDialog() {
    // Get the phone number from Firebase, with fallback
    final phoneNumber = _moreOptionsData?['requestHelp']?.toString() ?? '919566469670';
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0), // Light orange
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 32,
                  color: const Color(0xFFF57C00), // Orange
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'How would you like to contact us?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        try {
                          final Uri phoneUri = Uri(
                            scheme: 'tel',
                            path: phoneNumber,
                          );
                          await launchUrl(
                            phoneUri,
                            mode: LaunchMode.platformDefault,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error launching phone app'),
                              ),
                            );
                          }
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3E5F5), // Light purple
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 32,
                              color: const Color(0xFF7B1FA2), // Purple
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Call Us',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        try {
                          final Uri whatsappUri = Uri.parse(
                            'https://api.whatsapp.com/send?phone=$phoneNumber&text=Hello, I need help with Hassan Jewellers app.',
                          );
                          await launchUrl(
                            whatsappUri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Error launching WhatsApp'),
                              ),
                            );
                          }
                        }
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E8), // Light green
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.message,
                              size: 32,
                              color: const Color(0xFF388E3C), // Green
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'WhatsApp Us',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Under Maintenance',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.text,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We\'re currently performing some maintenance to improve your experience.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              // Maintenance Info Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Maintenance Icon
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Icon(
                        Icons.build_circle_outlined,
                        size: 30,
                        color: AppColors.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                                        // Message
                    Text(
                      'We\'re working hard to get everything back up and running smoothly.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.text,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Check Later Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Please check again later',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Contact Support
              TextButton(
                onPressed: () {
                  _showContactDialog();
                },
                child: Text(
                  'Contact Support',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
