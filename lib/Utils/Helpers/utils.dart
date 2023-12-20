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
