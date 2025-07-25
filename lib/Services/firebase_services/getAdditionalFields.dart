import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalField {
  final String name;
  final String label;
  final String type; // 'text', 'date', 'number', 'email', 'dropdown'
  final String? icon;
  final bool isRequired;
  final String? validation;
  final List<String>? options; // For dropdown fields
  final String? placeholder;
  final String? description;

  AdditionalField({
    required this.name,
    required this.label,
    required this.type,
    this.icon,
    this.isRequired = false,
    this.validation,
    this.options,
    this.placeholder,
    this.description,
  });

  factory AdditionalField.fromMap(Map<String, dynamic> map) {
    return AdditionalField(
      name: map['name'] ?? '',
      label: map['label'] ?? '',
      type: map['type'] ?? 'text',
      icon: map['icon'],
      isRequired: map['isRequired'] ?? false,
      validation: map['validation'],
      options: map['options'] != null ? List<String>.from(map['options']) : null,
      placeholder: map['placeholder'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'icon': icon,
      'isRequired': isRequired,
      'validation': validation,
      'options': options,
      'placeholder': placeholder,
      'description': description,
    };
  }
}

Future<List<AdditionalField>> getAdditionalFields() async {
  try {
    print('Fetching additional fields from Firestore...');
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
    
    final Map<String, dynamic> additionalFieldsMap = data['additionalFields'] ?? {};
    print('Additional fields map: $additionalFieldsMap');
    
    final List<AdditionalField> fields = [];
    
    additionalFieldsMap.forEach((fieldName, fieldData) {
      if (fieldData is Map<String, dynamic>) {
        // If fieldData is a map with field properties
        final field = AdditionalField.fromMap({
          'name': fieldName,
          ...fieldData,
        });
        fields.add(field);
      } else if (fieldData is List) {
        // If fieldData is a list (for dropdown options)
        final field = AdditionalField(
          name: fieldName,
          label: fieldName,
          type: 'dropdown',
          options: fieldData.map((item) => item.toString()).toList(),
        );
        fields.add(field);
      } else {
        // If fieldData is a simple value (string, etc.)
        final field = AdditionalField(
          name: fieldName,
          label: fieldName,
          type: 'text',
          placeholder: fieldData?.toString() ?? '',
        );
        fields.add(field);
      }
    });
    
    print('Parsed additional fields: ${fields.map((f) => '${f.name}: ${f.type}').toList()}');
    
    return fields;
  } catch (e) {
    print('Error fetching additional fields: $e');
    return [];
  }
} 