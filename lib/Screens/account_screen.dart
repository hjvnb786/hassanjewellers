import 'package:flutter/material.dart';
import 'package:hassanjewellers/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hassanjewellers/Services/firebase_services/signOut.dart';
import 'package:hassanjewellers/Services/firebase_services/get_user_data.dart';
import 'package:hassanjewellers/Services/firebase_services/delete_address.dart';
import 'package:hassanjewellers/Services/firebase_services/get_more_options.dart';
import 'package:hassanjewellers/Services/firebase_services/migrateAdditionalDetails.dart';
import 'package:hassanjewellers/Screens/address_form_screen.dart';
import 'package:hassanjewellers/Widgets/address_shimmer_loading.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Map<String, dynamic>? _userData;
  Map<String, dynamic>? _moreOptionsData;
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoadingUserData = true;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingUserData = true;
    });
    
    // Load both user data and more options data
    final userData = await getUserData();
    final moreOptionsData = await getMoreOptions();
    
    print('Loaded user data: ${userData != null ? 'success' : 'failed'}'); // Debug print
    print('Loaded more options data: ${moreOptionsData != null ? 'success' : 'failed'}'); // Debug print
    
    if (mounted) {
      setState(() {
        _userData = userData;
        _moreOptionsData = moreOptionsData;
        // Extract addresses from user data
        if (userData != null) {
          final addresses = userData['addresses'] as List<dynamic>?;
          _addresses = addresses?.map((address) => Map<String, dynamic>.from(address)).toList() ?? [];
        }
        _isLoadingUserData = false;
      });
      print('State updated with user data and ${_addresses.length} addresses'); // Debug print
    }
  }

  Future<void> _forceReloadUserData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingUserData = true;
      _userData = null;
      _addresses = [];
    });
    
    // Wait a bit longer to ensure Firebase cache is cleared
    await Future.delayed(const Duration(milliseconds: 500));
    
    final userData = await getUserData();
    print('Force reloaded user data: ${userData != null ? 'success' : 'failed'}'); // Debug print
    
    if (mounted && userData != null) {
      setState(() {
        _userData = userData;
        // Extract addresses from user data
        final addresses = userData['addresses'] as List<dynamic>?;
        _addresses = addresses?.map((address) => Map<String, dynamic>.from(address)).toList() ?? [];
        _isLoadingUserData = false;
        _refreshKey++; // Increment refresh key
      });
      print('Force reload state updated with user data and ${_addresses.length} addresses'); // Debug print
    } else if (mounted) {
      setState(() {
        _isLoadingUserData = false;
      });
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
    ).then((_) => _loadUserData());
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
        await _forceReloadUserData();
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
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
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
                    if (_isLoadingUserData) ...[
                      // Shimmer for profile avatar
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Shimmer for profile name
                      Container(
                        width: 150,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey.shade50,
                            ),
                            child: Center(
                              child: Text(
                                _userData?['firstName']?.toString().isNotEmpty == true 
                                    ? _userData!['firstName'][0].toUpperCase() 
                                    : '?',
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}'.trim().isNotEmpty 
                            ? '${_userData?['firstName'] ?? ''} ${_userData?['lastName'] ?? ''}'.trim()
                            : 'User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                        if (_isLoadingUserData) ...[
                          // Shimmer loading for profile info cards
                          _buildShimmerInfoCard(),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildShimmerInfoCard(),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildShimmerInfoCard(),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildShimmerInfoCard(),
                        ] else ...[
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            title: 'First Name',
                            content: _userData?['firstName']?.toString() ?? 'Not provided',
                          ),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildInfoCard(
                            icon: Icons.person_outline,
                            title: 'Last Name',
                            content: _userData?['lastName']?.toString() ?? 'Not provided',
                          ),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildInfoCard(
                            icon: Icons.phone_outlined,
                            title: 'Phone',
                            content: _userData?['phone']?.toString() ?? 'Not provided',
                          ),
                          const Divider(height: 0, indent: 16, endIndent: 16),
                          _buildInfoCard(
                            icon: Icons.email_outlined,
                            title: 'Email',
                            content: _userData?['email']?.toString() ?? 'Not provided',
                          ),
                        ],
                        
                        
                        // Display existing addresses within Account Information
                        if (_isLoadingUserData) ...[
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
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFFF3E0), // Light orange
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.point_of_sale,
                                            color: const Color(0xFFF57C00), // Orange
                                            size: 24,
                                          ),
                                        ),
                                        // Icon(
                                        //   Icons.location_on_outlined,
                                        //   color: Colors.grey[600],
                                        //   size: 24,
                                        // ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Address',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${address['firstName']} ${address['lastName']}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
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
                                    const SizedBox(height: 8),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(64.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        '${address['aptFloorDoorNumber']}, ${address['streetName']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(64.0, 0.0, 0.0, 0.0),
                                      child: Text(
                                        '${address['city']}, ${address['state']} - ${address['pincode']}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(64.0, 0.0, 0.0, 0.0),
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
                        GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddressFormScreen(),
                              ),
                            );
                            _loadUserData();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE1F5FE), // Light cyan
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.add_location_outlined,
                                    color: const Color(0xFF0097A7), // Cyan
                                    size: 24,
                                  ),
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

                              ],
                            ),
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
                          subtitle: 'Spread the word about Hassan Jewellers',
                          onTap: () => _shareApp(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.location_on_outlined,
                          title: 'Visit Our Store',
                          subtitle: 'Find us and explore our collection',
                          onTap: () => _launchMaps(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.help_outline,
                          title: 'Request Help',
                          subtitle: 'We\'re here to assist you',
                          onTap: () => _showHelpDialog(),
                        ),
                        const Divider(height: 0, indent: 16, endIndent: 16),
                        _buildActionCard(
                          icon: Icons.sync,
                          title: 'Migrate Data',
                          subtitle: 'Update existing scheme data structure',
                          onTap: () => _showMigrationDialog(),
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

  Widget _buildShimmerInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Shimmer for icon container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          // Shimmer for text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer for title
                Container(
                  width: 80,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                // Shimmer for content
                Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
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
    // Define different light colors for each icon based on title
    Color getIconColor(String title) {
      switch (title.toLowerCase()) {
        case 'first name':
          return const Color(0xFFE3F2FD); // Light blue
        case 'last name':
          return const Color(0xFFE1F5FE); // Light cyan
        case 'phone':
          return const Color(0xFFF3E5F5); // Light purple
        case 'email':
          return const Color(0xFFE8F5E8); // Light green
        default:
          return Theme.of(context).primaryColor.withOpacity(0.1);
      }
    }

    Color getIconTintColor(String title) {
      switch (title.toLowerCase()) {
        case 'first name':
          return const Color(0xFF1976D2); // Blue
        case 'last name':
          return const Color(0xFF0097A7); // Cyan
        case 'phone':
          return const Color(0xFF7B1FA2); // Purple
        case 'email':
          return const Color(0xFF388E3C); // Green
        default:
          return Theme.of(context).primaryColor;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
                      Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: getIconColor(title),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: getIconTintColor(title),
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
    String? subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    // Define different light colors for action icons based on title
    Color getActionIconColor(String title) {
      switch (title.toLowerCase()) {
        case 'share app':
          return const Color(0xFFE8F5E8); // Light green
        case 'visit our store':
          return const Color(0xFFE3F2FD); // Light blue
        case 'request help':
          return const Color(0xFFFFF3E0); // Light orange
        case 'log out':
          return const Color(0xFFFFEBEE); // Light red
        default:
          return Theme.of(context).primaryColor.withOpacity(0.1);
      }
    }

    Color getActionIconTintColor(String title) {
      switch (title.toLowerCase()) {
        case 'share app':
          return const Color(0xFF388E3C); // Green
        case 'visit our store':
          return const Color(0xFF1976D2); // Blue
        case 'request help':
          return const Color(0xFFF57C00); // Orange
        case 'log out':
          return const Color(0xFFD32F2F); // Red
        default:
          return Theme.of(context).primaryColor;
      }
    }

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
                color: getActionIconColor(title),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: getActionIconTintColor(title),
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
                      color: isLogout ? getActionIconTintColor(title) : null,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
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
    // Get the Google Maps link from Firebase, with fallback
    final mapsLink = _moreOptionsData?['visitOurStore']?.toString() ?? 'https://www.google.com/maps/search/?api=1&query=Hassan+Jewellers';
    
    // Debug logging
    print('More options data: $_moreOptionsData');
    print('Maps link from Firebase: ${_moreOptionsData?['visitOurStore']}');
    print('Final maps link: $mapsLink');
    
    try {
      final Uri mapsUri = Uri.parse(mapsLink);
      await launchUrl(
        mapsUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      print('Error launching maps: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error launching maps'),
          ),
        );
      }
    }
  }

  void _shareApp() {
    // Get the share message from Firebase, with fallback
    final shareMessage = _moreOptionsData?['shareApp']?.toString() ?? 'Check out Hassan Jewellers app! Download it now.';
    
    // Show a dialog with sharing options
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share App'),
        content: Text(shareMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('App sharing feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Copy Text'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
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

  void _showMigrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Migrate Data Structure'),
        content: const Text(
          'This will update existing scheme documents to move additional details to a separate section. '
          'This is a one-time operation to improve data organization. '
          'Do you want to proceed?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _runMigration();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Migrate'),
          ),
        ],
      ),
    );
  }

  Future<void> _runMigration() async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Migrating data...'),
          ],
        ),
      ),
    );

    try {
      await migrateAdditionalDetails();
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Complete'),
            content: const Text(
              'Your scheme data has been successfully migrated to the new structure. '
              'Additional details are now organized separately for better data management.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Migration Failed'),
            content: Text('An error occurred during migration: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }
}
