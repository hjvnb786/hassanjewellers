import 'package:flutter/material.dart';
import 'package:hassanjewellers/main.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hassanjewellers/Services/firebase_services/signOut.dart';
import 'package:hassanjewellers/Services/firebase_services/get_user_addresses.dart';
import 'package:hassanjewellers/Services/firebase_services/delete_address.dart';
import 'package:hassanjewellers/Screens/address_form_screen.dart';
import 'package:hassanjewellers/Widgets/address_shimmer_loading.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.email,
  });

  final String name;
  final String phone;
  final String email;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoadingAddresses = true;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingAddresses = true;
    });
    
    final addresses = await getUserAddresses();
    print('Loaded addresses: ${addresses.length}'); // Debug print
    
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _isLoadingAddresses = false;
      });
      print('State updated with ${_addresses.length} addresses'); // Debug print
    }
  }

  Future<void> _forceReloadAddresses() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingAddresses = true;
      _addresses = [];
    });
    
    // Wait a bit longer to ensure Firebase cache is cleared
    await Future.delayed(const Duration(milliseconds: 500));
    
    final addresses = await getUserAddresses();
    print('Force reloaded addresses: ${addresses.length}'); // Debug print
    
    if (mounted) {
      setState(() {
        _addresses = addresses;
        _isLoadingAddresses = false;
        _refreshKey++; // Increment refresh key
      });
      print('Force reload state updated with ${_addresses.length} addresses'); // Debug print
    }
  }

  void _editAddress(Map<String, dynamic> address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressFormScreen(
          addressData: address,
          addressId: address['id'],
        ),
      ),
    ).then((_) => _loadAddresses());
  }

  Future<void> _deleteAddress(String addressId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await deleteUserAddress(addressId);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Address deleted successfully!'),
              backgroundColor: Colors.green[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        // Use force reload method
        await _forceReloadAddresses();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to delete address. Please try again.'),
              backgroundColor: Colors.red[600],
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Account Information
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                    child: Column(
                      children: [
                        _buildInfoCard(
                          icon: Icons.person_outline,
                          title: 'Name',
                          content: widget.name,
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildInfoCard(
                          icon: Icons.phone_outlined,
                          title: 'Phone',
                          content: widget.phone,
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildInfoCard(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          content: widget.email,
                        ),
                        // Display existing addresses within Account Information
                        if (_isLoadingAddresses) ...[
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: List.generate(2, (index) => const AddressShimmerLoading()),
                            ),
                          ),
                        ] else if (_addresses.isNotEmpty) ...[
                          ..._addresses.map((address) => Column(
                            children: [
                              const Divider(height: 0, indent: 16, endIndent: 16),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                Icons.location_on_outlined,
                                                color: Theme.of(context).primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Text(
                                                'Address',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),
                                            // Edit and Delete Icons at top right
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Edit Icon
                                                GestureDetector(
                                                  onTap: () => _editAddress(address),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blue.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.edit_outlined,
                                                      size: 18,
                                                      color: Colors.blue[600],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                // Delete Icon
                                                GestureDetector(
                                                  onTap: () => _deleteAddress(address['id']),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Icon(
                                                      Icons.delete_outline,
                                                      size: 18,
                                                      color: Colors.red[600],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Padding(
                                          padding: const EdgeInsets.only(left: 52.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${address['firstName']} ${address['lastName']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                '${address['aptFloorDoorNumber']}, ${address['streetName']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${address['city']}, ${address['state']} - ${address['pincode']}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${address['mobileNumber'] ?? ''}${address['alternativeMobileNumber'] != null && address['alternativeMobileNumber'].toString().isNotEmpty ? ' / ${address['alternativeMobileNumber']}' : ''}',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                      child: Text(
                                        '${address['mobileNumber'] ?? ''}${address['alternativeMobileNumber'] != null && address['alternativeMobileNumber'].toString().isNotEmpty ? ' / ${address['alternativeMobileNumber']}' : ''}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )).toList(),
                        ],
                        // Add Address Button (always shown, below existing addresses)
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.add_location_outlined,
                                color: Colors.grey[600],
                                size: 24,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add Address',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Add your delivery address',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AddressFormScreen(),
                                    ),
                                  );
                                  _loadAddresses();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.add,
                                    size: 20,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Grouped Actions Section
                  const Text(
                    'More Options',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
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
                    child: Column(
                      children: [
                        _buildActionCard(
                          icon: Icons.share_outlined,
                          title: 'Share App',
                          subtitle: 'Share with friends and family',
                          onTap: () => _shareApp(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.location_on_outlined,
                          title: 'Visit Our Store',
                          subtitle: '123 Jewelry Street, City',
                          onTap: () => _launchMaps(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.help_outline,
                          title: 'Request Help',
                          subtitle: 'Get assistance from our team',
                          onTap: () => _showHelpDialog(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.logout,
                          title: 'Log Out',
                          subtitle: 'Sign out of your account',
                          onTap: () => _showLogoutDialog(context),
                          isLogout: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isLogout 
                    ? Colors.red.withOpacity(0.1)
                    : Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isLogout ? Colors.red[400] : Theme.of(context).primaryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isLogout ? Colors.red[400] : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
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
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.logout,
                  size: 32,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to log out?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  ElevatedButton(
                    onPressed: () async {
                      await signOut();
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => MyApp()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Log Out',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  void _launchMaps() async {
    // Replace with your store's actual coordinates
    const url = 'https://www.google.com/maps/search/?api=1&query=YOUR_STORE_COORDINATES';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _shareApp() {
    Share.share('Check out Hassan Jewellers app! Download it now.');
  }

  void _showHelpDialog() {
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
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.help_outline,
                  size: 32,
                  color: Theme.of(context).primaryColor,
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
                            path: '919566469670',
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
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 32,
                              color: Theme.of(context).primaryColor,
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
                            'https://api.whatsapp.com/send?phone=919566469670&text=Hello, I need help with Hassan Jewellers app.',
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.message,
                              size: 32,
                              color: Colors.green[600],
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
}
