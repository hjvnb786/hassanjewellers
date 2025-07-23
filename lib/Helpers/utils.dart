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

List<Map<String, dynamic>> generateProgress() {
  List<Map<String, dynamic>> listOfMaps = [];
  DateTime currentDate = DateTime.now();

  for (int i = 0; i < 12; i++) {
    Map<String, dynamic> map = {'paid': false};
    listOfMaps.add(map);
  }

  listOfMaps[0]['paid'] = true;
  listOfMaps[0]['date'] = currentDate;
  return listOfMaps;
}

List<Map<String, dynamic>> getProgressList(List<dynamic> progress) {
  List<String> installmentLabels = [
    "First Installment",
    "Second Installment",
    "Third Installment",
    "Fourth Installment",
    "Fifth Installment",
    "Sixth Installment",
    "Seventh Installment",
    "Eighth Installment",
    "Ninth Installment",
    "Tenth Installment",
    "Eleventh Installment",
    "Twelfth Installment",
  ];

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
