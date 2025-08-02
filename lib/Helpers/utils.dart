import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ntp/ntp.dart';

Future<DateTime> getAccurateTime() async {
  List<String> ntpServers = [
    'time.google.com',
    'time.facebook.com',
    'time.euro.apple.com',
    'pool.ntp.org',
  ];

  for (String ntpServer in ntpServers) {
    try {
      int offset = await NTP.getNtpOffset(
          localTime: DateTime.now(), lookUpAddress: ntpServer);
      DateTime accurateTime =
          DateTime.now().add(Duration(milliseconds: offset));
      return accurateTime;
    } catch (e) {
      print('Failed to fetch accurate time from $ntpServer: $e');
    }
  }

  return DateTime.now();
}

List<Map<String, dynamic>> generateProgress({int? duration, String? paymentReference, Map<String, dynamic>? paymentResponse}) {
  List<Map<String, dynamic>> listOfMaps = [];
  DateTime currentDate = DateTime.now();
  
  // Use provided duration or default to 12 months
  final months = duration ?? 12;

  for (int i = 0; i < months; i++) {
    Map<String, dynamic> map = {'paid': false};
    listOfMaps.add(map);
  }

  // Mark first month as paid
  listOfMaps[0]['paid'] = true;
  listOfMaps[0]['date'] = currentDate;
  
  // Add complete payment response if provided
  if (paymentResponse != null) {
    listOfMaps[0]['paymentResponse'] = paymentResponse;
    print("✅ Complete payment response stored in first month");
    print("📊 Payment response data: $paymentResponse");
  }
  
  return listOfMaps;
}

List<Map<String, dynamic>> getProgressList(List<dynamic> progress) {
  // Helper function to get ordinal suffix
  String _getOrdinal(int number) {
    if (number >= 11 && number <= 13) {
      return '${number}th';
    }
    switch (number % 10) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }

  // Generate dynamic installment labels based on progress length
  List<String> generateInstallmentLabels(int length) {
    List<String> labels = [];
    for (int i = 0; i < length; i++) {
      String ordinal = _getOrdinal(i + 1);
      labels.add("${ordinal} Installment");
    }
    return labels;
  }

  final installmentLabels = generateInstallmentLabels(progress.length);

  final progressValue = progress.asMap().entries.map((entry) {
    int index = entry.key;
    Map<String, dynamic> element = entry.value;

    String formattedDate = "";

    String getMonthName(int month) {
      const List<String> monthNames = [
        "January",
        "February",
        "March",
        "April",
        "May",
        "June",
        "July",
        "August",
        "September",
        "October",
        "November",
        "December"
      ];
      return monthNames[month - 1]; // Adjust for 0-based indexing
    }

    if (element["date"] != null) {
      Timestamp timestamp = element["date"];
      DateTime dateTime = timestamp.toDate();
      //formattedDate = "${dateTime.day}-${dateTime.month}-${dateTime.year}";
      formattedDate =
          "${dateTime.day} ${getMonthName(dateTime.month)} ${dateTime.year}";
    }

    return {
      'paid': element['paid'],
      'label': installmentLabels[index],
      'date': formattedDate,
      'referenceId': element['referenceId']
    };
  }).toList();

  return progressValue;
}
