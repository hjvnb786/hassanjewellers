import 'package:cloud_firestore/cloud_firestore.dart';

class OrderIdData {
  final String yearCode;
  final Map<String, String> amountCode;
  final int sequenceNumber;

  OrderIdData({
    required this.yearCode,
    required this.amountCode,
    required this.sequenceNumber,
  });

  factory OrderIdData.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    print("🔍 Raw Firestore data: $data");
    print("🔍 yearCode: ${data['yearCode']}");
    print("🔍 amountCode: ${data['amountCode']}");
    print("🔍 sequenceNumber: ${data['sequenceNumber']}");
    
    return OrderIdData(
      yearCode: data['yearCode'] ?? '',
      amountCode: Map<String, String>.from(data['amountCode'] ?? {}),
      sequenceNumber: data['sequenceNumber'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'yearCode': yearCode,
      'amountCode': amountCode,
      'sequenceNumber': sequenceNumber,
    };
  }
}

Future<String> generateOrderId(String amount) async {
  print("🔄 Generating order ID for amount: $amount");
  
  // Get the orderID document from Firestore
  DocumentReference orderIdRef = FirebaseFirestore.instance
      .collection('info')
      .doc('orderID'); // Changed from 'orderId' to 'orderID'
  
  // Use a transaction to ensure atomic read and write
  String orderId = await FirebaseFirestore.instance.runTransaction<String>((transaction) async {
    // Read the current orderID document
    DocumentSnapshot orderIdDoc = await transaction.get(orderIdRef);
    
    print("📄 Document exists: ${orderIdDoc.exists}");
    if (orderIdDoc.exists) {
      print("📄 Document data: ${orderIdDoc.data()}");
    }
    
    if (!orderIdDoc.exists) {
      throw Exception('OrderID document not found in Firestore');
    }
    
    // Parse the document data
    OrderIdData orderIdData = OrderIdData.fromFirestore(orderIdDoc);
    
    print("📊 Parsed data - yearCode: ${orderIdData.yearCode}, amountCode: ${orderIdData.amountCode}, sequenceNumber: ${orderIdData.sequenceNumber}");
    
    // Get the amount code
    String amountCode = orderIdData.amountCode[amount] ?? 'X';
    if (amountCode == 'X') {
      print("⚠️ Warning: No amount code found for amount $amount, using 'X'");
      print("🔍 Available amounts: ${orderIdData.amountCode.keys.toList()}");
    }
    
    // Generate the order ID
    String sequenceString = orderIdData.sequenceNumber.toString();
    String generatedOrderId = '${orderIdData.yearCode}$amountCode$sequenceString';
    
    print("📝 Generated order ID: $generatedOrderId");
    print("📊 Components: YearCode=${orderIdData.yearCode}, AmountCode=$amountCode, Sequence=${orderIdData.sequenceNumber}");
    
    // Note: We don't increment the sequence number here
    // It will be incremented after successful payment
    
    return generatedOrderId;
  });
  
  return orderId;
}

Future<void> incrementOrderSequence() async {
  print("🔄 Incrementing order sequence number...");
  
  DocumentReference orderIdRef = FirebaseFirestore.instance
      .collection('info')
      .doc('orderID'); // Changed from 'orderId' to 'orderID'
  
  await FirebaseFirestore.instance.runTransaction((transaction) async {
    DocumentSnapshot orderIdDoc = await transaction.get(orderIdRef);
    
    if (!orderIdDoc.exists) {
      throw Exception('OrderID document not found in Firestore');
    }
    
    OrderIdData orderIdData = OrderIdData.fromFirestore(orderIdDoc);
    
    // Increment the sequence number
    int newSequence = orderIdData.sequenceNumber + 1;
    
    // Update the document
    transaction.update(orderIdRef, {
      'sequenceNumber': newSequence,
    });
    
    print("✅ Sequence number incremented to: $newSequence");
  });
}

// Helper function to create the orderID document if it doesn't exist
Future<void> createOrderIdDocumentIfNotExists() async {
  print("🔧 Checking if orderID document exists...");
  
  DocumentReference orderIdRef = FirebaseFirestore.instance
      .collection('info')
      .doc('orderID'); // Changed from 'orderId' to 'orderID'
  
  DocumentSnapshot orderIdDoc = await orderIdRef.get();
  
  if (!orderIdDoc.exists) {
    print("📝 Creating orderID document in Firestore...");
    
    Map<String, dynamic> orderIdData = {
      'yearCode': 'RC',
      'amountCode': {
        '1000': 'A',
        '2000': 'B',
        '5000': 'C',
        '10000': 'D',
      },
      'sequenceNumber': 1,
    };
    
    await orderIdRef.set(orderIdData);
    print("✅ orderID document created successfully!");
  } else {
    print("✅ orderID document already exists");
  }
} 