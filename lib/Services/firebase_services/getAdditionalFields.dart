import 'package:cloud_firestore/cloud_firestore.dart';

class AdditionalField {
  final String name;
  final String label;
  final String type; // 'text', 'date', 'number', 'email', 'dropdown', 'group'
  final String? icon;
  final bool isRequired;
  final String? validation;
  final List<String>? options; // For dropdown fields
  final String? placeholder;
  final String? description;
  final String? dependsOn; // Field this depends on
  final Map<String, AdditionalField>? fields; // For group type fields

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
    this.dependsOn,
    this.fields,
  });

  factory AdditionalField.fromMap(Map<String, dynamic> map) {
    Map<String, AdditionalField>? groupFields;
    
    if (map['type'] == 'group' && map['fields'] != null) {
      groupFields = {};
      final fieldsMap = map['fields'] as Map<String, dynamic>;
      fieldsMap.forEach((fieldName, fieldData) {
        if (fieldData is Map<String, dynamic>) {
          groupFields![fieldName] = AdditionalField.fromMap({
            'name': fieldName,
            ...fieldData,
          });
        }
      });
    }

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
      dependsOn: map['dependsOn'],
      fields: groupFields,
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
      'dependsOn': dependsOn,
      'fields': fields?.map((key, value) => MapEntry(key, value.toMap())),
    };
  }
}

Future<void> printRawData() async {
  try {
    print('=== FETCHING RAW DATA FROM INFO COLLECTION ===');
    final DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection('info')
        .doc('plans')
        .get();

    print('Document exists: ${documentSnapshot.exists}');
    
    if (!documentSnapshot.exists) {
      print('Document does not exist');
      return;
    }

    final data = documentSnapshot.data() as Map<String, dynamic>;
    print('=== RAW DATA ===');
    print(data);
    print('=== END RAW DATA ===');
    
    final Map<String, dynamic> additionalFieldsMap = data['additionalField'] ?? {};
    print('=== ADDITIONAL FIELDS MAP ===');
    print(additionalFieldsMap);
    print('=== END ADDITIONAL FIELDS MAP ===');
    
  } catch (e) {
    print('Error fetching raw data: $e');
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
    
    final Map<String, dynamic> additionalFieldsMap = data['additionalField'] ?? {};
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