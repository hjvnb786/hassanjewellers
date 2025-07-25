import 'package:cloud_firestore/cloud_firestore.dart';

class Plan {
  final String name;
  final String description;
  final int duration;
  final List<int> monthlyAmount;

  Plan({
    required this.name,
    required this.description,
    required this.duration,
    required this.monthlyAmount,
  });

  factory Plan.fromMap(Map<String, dynamic> map) {
    return Plan(
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      duration: map['duration'] ?? 0,
      monthlyAmount: List<int>.from(map['monthlyAmount'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'duration': duration,
      'monthlyAmount': monthlyAmount,
    };
  }
}

Future<List<Plan>> getPlans() async {
  try {
    print('Fetching plans from Firestore...');
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('info')
        .doc('plans')
        .get();

    print('Document exists: ${documentSnapshot.exists}');
    
    if (!documentSnapshot.exists) {
      print('Document does not exist, returning empty list');
      return [];
    }

    final data = documentSnapshot.data() as Map<String, dynamic>;
    print('Raw data: $data');
    
    // Changed from 'plans' to 'schemeTypes' based on actual data structure
    final List<dynamic> plansList = data['schemeTypes'] ?? [];
    print('Plans list length: ${plansList.length}');
    print('Plans list: $plansList');

    final plans = plansList.map((planData) => Plan.fromMap(planData)).toList();
    print('Parsed plans: ${plans.map((p) => p.name).toList()}');
    
    return plans;
  } catch (e) {
    print('Error fetching plans: $e');
    return [];
  }
} 