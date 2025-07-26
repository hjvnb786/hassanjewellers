import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Widgets/scheme_item.dart';
import 'package:hassanjewellers/Screens/join_new_scheme_screen.dart';
import 'package:hassanjewellers/Services/firebase_services/getCurrentUser.dart';
import 'package:hassanjewellers/Utils/Constants/colors.dart';

class SchemesScreen extends StatefulWidget {
  const SchemesScreen({super.key});

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
  double totalSavings = 0.0;
  double totalTargetAmount = 0.0;
  double overallProgress = 0.0;

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

      // Get scheme statistics
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

      double totalSaved = 0.0;
      double totalTarget = 0.0;
      
      // Calculate active schemes stats
      for (var doc in activeSchemes.docs) {
        final data = doc.data();
        final installmentAmount = data["installmentAmount"] ?? 0.0;
        final progress = data["progress"] ?? 0.0;
        final targetAmount = data["targetAmount"] ?? 0.0;
        
        totalSaved += progress * installmentAmount;
        totalTarget += targetAmount;
      }

      // Calculate completed schemes stats
      for (var doc in completedSchemes.docs) {
        final data = doc.data();
        final targetAmount = data["targetAmount"] ?? 0.0;
        totalTarget += targetAmount;
        totalSaved += targetAmount; // Completed schemes are fully saved
      }

      double progress = totalTarget > 0 ? (totalSaved / totalTarget) * 100 : 0.0;

      setState(() {
        activeSchemesCount = activeSchemes.docs.length;
        completedSchemesCount = completedSchemes.docs.length;
        totalSavings = totalSaved;
        totalTargetAmount = totalTarget;
        overallProgress = progress;
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
              expandedHeight: 320.0,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                        AppColors.primaryDark,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Welcome Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 28,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome back${customerName.isNotEmpty ? ', $customerName' : ''}!",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Text(
                                      "Manage your savings schemes",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Stats Cards
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.account_balance_wallet,
                                  title: "Total Saved",
                                  value: "₹${totalSavings.toStringAsFixed(0)}",
                                  subtitle: "Current Savings",
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  icon: Icons.trending_up,
                                  title: "Total Target",
                                  value: "₹${totalTargetAmount.toStringAsFixed(0)}",
                                  subtitle: "Goal Amount",
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                padding: const EdgeInsets.only(top: 8, left: 20, right: 20),
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

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const JoinNewSchemeScreen()),
                      );
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
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SchemeItem(
                id: data.id,
                name: data["name"],
                amount: data["installmentAmount"],
                progress: data["progress"],
                schemeDetails: data.data() as Map<String, dynamic>,
              ),
            );
          },
        );
      },
    );
  }
}
