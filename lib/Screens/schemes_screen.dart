import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Widgets/scheme_item.dart';
import 'package:hassanjewellers/Screens/join_new_scheme_screen.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';

class SchemesScreen extends StatefulWidget {
  final VoidCallback? onStartNewScheme;
  
  const SchemesScreen({super.key, this.onStartNewScheme});

  @override
  State<SchemesScreen> createState() => _SchemesScreenState();
}

class _SchemesScreenState extends State<SchemesScreen> with TickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  late final TabController _tabController;
  final uid = getCurrentUser()?.uid;
  late Stream<QuerySnapshot<Map<String, dynamic>>> activeSchemeList;
  late Stream<QuerySnapshot<Map<String, dynamic>>> closedSchemeList;
  String customerName = "";
  int activeSchemesCount = 0;
  int completedSchemesCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    activeSchemeList = _firestore
        .collection("savings")
        .where("userId", isEqualTo: uid)
        .where("status", isEqualTo: true)
        .snapshots();

    closedSchemeList = _firestore
        .collection("savings")
        .where("userId", isEqualTo: uid)
        .where("status", isEqualTo: false)
        .snapshots();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userDoc = await _firestore.collection("users").doc(uid).get();
      if (userDoc.exists) {
        setState(() {
          customerName = userDoc.data()?["name"] ?? "";
        });
      }

      // Get scheme counts
      final activeSchemes = await _firestore
          .collection("savings")
          .where("userId", isEqualTo: uid)
          .where("status", isEqualTo: true)
          .get();

      final completedSchemes = await _firestore
          .collection("savings")
          .where("userId", isEqualTo: uid)
          .where("status", isEqualTo: false)
          .get();

      setState(() {
        activeSchemesCount = activeSchemes.docs.length;
        completedSchemesCount = completedSchemes.docs.length;
      });
    } catch (e) {
      print("Error loading user data: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 140.0, // Reduced height for cleaner layout
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryDark,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Logo and Welcome Message Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Circular Logo Card
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: Image.asset(
                                    'assets/logo.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Welcome Texts
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Hassan Jewellers",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      customerName.isNotEmpty ? "Welcome, $customerName" : "Welcome back!",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                      ),
                                      textAlign: TextAlign.left,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                indicatorSize: TabBarIndicatorSize.tab,
                padding: const EdgeInsets.only(left: 20, right: 20), // Removed top: 8
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.7),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: const <Widget>[
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.trending_up, size: 18),
                        SizedBox(width: 8),
                        Text("Active Schemes"),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 18),
                        SizedBox(width: 8),
                        Text("Completed"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildSchemeList(activeSchemeList, true),
            _buildSchemeList(closedSchemeList, false),
          ],
        ),
      ),
    );
  }



  Widget _buildSchemeList(Stream<QuerySnapshot> stream, bool isActive) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: Colors.red[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.red[300],
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final schemes = snapshot.data?.docs;
        
        if (schemes == null || schemes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isActive ? Icons.account_balance_wallet_outlined : Icons.history,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  isActive
                      ? 'No active schemes yet'
                      : 'No completed schemes yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isActive
                      ? 'Start a new scheme to begin saving'
                      : 'Your completed schemes will appear here',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                if (isActive)
                  ElevatedButton.icon(
                    onPressed: () {
                      if (widget.onStartNewScheme != null) {
                        widget.onStartNewScheme!();
                      } else {
                        // Fallback to original navigation if no callback provided
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const JoinNewSchemeScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Start New Scheme'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: schemes.length,
          itemBuilder: (context, index) {
            final data = schemes[index];
            final personalDetails = data["personalDetails"] as Map<String, dynamic>? ?? {};
            final schemeDetails = data["schemeDetails"] as Map<String, dynamic>? ?? {};
            final schemeProgress = data["schemeProgress"] as Map<String, dynamic>? ?? {};
            
            // Extract data from new nested structure
            final firstName = personalDetails["firstName"] ?? '';
            final lastName = personalDetails["lastName"] ?? '';
            final name = '$firstName $lastName'.trim();
            final amount = schemeDetails["installmentAmount"] ?? '';
            final progress = schemeProgress["installments"] ?? [];
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SchemeItem(
                id: data.id,
                name: name,
                amount: amount,
                progress: progress,
                schemeDetails: data.data() as Map<String, dynamic>,
              ),
            );
          },
        );
      },
    );
  }
}
