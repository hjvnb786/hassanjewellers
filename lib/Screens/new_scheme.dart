import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hassanjewellers/Components/drop_down_field.dart';
import 'package:hassanjewellers/Components/user_text_input_field.dart';
import 'package:ntp/ntp.dart';

class NewScheme extends StatefulWidget {
  const NewScheme({super.key});

  @override
  State<NewScheme> createState() => _NewSchemeState();
}

class _NewSchemeState extends State<NewScheme> {
  final _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController fatherMotherHusbandController = TextEditingController();
  TextEditingController nomineeNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();
  TextEditingController mailController = TextEditingController();
  TextEditingController alternateMobileController = TextEditingController();
  TextEditingController applicantIDProofController = TextEditingController();
  TextEditingController nomineeIDProofController = TextEditingController();

  List<String> monthlyInstallmentAmounts = [
    '500 ₹',
    '1000 ₹',
    '2000 ₹',
    '5000 ₹',
    '10000 ₹'
  ];

  List<String> occupationList = [
    'Business',
    'Housewife',
    'Employee',
    'Child',
    'Teacher'
  ];

  List<String> nomineeList = [
    'Father',
    'Mother',
    'Spouse',
    'Son',
    'Daughter',
    'Brother',
    'Sister',
    'Uncle',
    'Aunt',
    'Grand Father',
    'Grand Mother',
    'Nephew',
    'Niece'
  ];

  String monthlySelectedAmount = "500 ₹";
  String selectedOccupation = "Business";
  String selectedNominee = "Father";



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

  void setSelectedDropDownOption(String label, String value) {
    setState(() {
      if (label == "Installment Amount") {
        monthlySelectedAmount = value;
      } else if (label == "Occupation") {
        selectedOccupation = value;
      } else if (label == "Relationship with nominee") {
        selectedNominee = value;
      }
    });
  }

  void submitData() {
    _firestore.collection('savings').add({
      "userId": FirebaseAuth.instance.currentUser!.uid.toString(),
      "name": nameController.text,
      "installmentAmount": monthlySelectedAmount,
      "guardianName": fatherMotherHusbandController.text,
      "occupation": selectedOccupation,
      "nomineeName": nomineeNameController.text,
      "nomineeRelation": selectedNominee,
      "address": addressController.text,
      "age": ageController.text,
      "mobileNumber": mobileNumberController.text,
      "mail": mailController.text,
      "alternateMobile": alternateMobileController.text,
      "applicantIDProof": applicantIDProofController.text,
      "nomineeIDProof": nomineeIDProofController.text,
      "date": DateTime.now(),
      "progress": generateProgress()
    });
  }

  Future<void> domains() async {
    [
      'time.google.com',
      'time.facebook.com',
      'time.euro.apple.com',
      'pool.ntp.org',
    ].forEach(checkTime);
  }

  Future<void> checkTime(String lookupAddress) async {
    DateTime _myTime;
    DateTime _ntpTime;

    /// Or you could get NTP current (It will call DateTime.now() and add NTP offset to it)
    _myTime = DateTime.now();

    /// Or get NTP offset (in milliseconds) and add it yourself
    final int offset =
    await NTP.getNtpOffset(localTime: _myTime, lookUpAddress: lookupAddress);

    _ntpTime = _myTime.add(Duration(milliseconds: offset));

    print('\n==== $lookupAddress ====');
    print('My time: $_myTime');
    print('NTP time: $_ntpTime');
    print('Difference: ${_myTime.difference(_ntpTime).inMilliseconds}ms');

    return;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    domains();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join New Scheme"),
      ),
      body: ListView(
        children: [
          UserDropDownField(
              label: "Installment Amount",
              selectionList: monthlyInstallmentAmounts,
              selectedItem: monthlySelectedAmount,
              setSelectedItem: setSelectedDropDownOption),
          UserTextInputField(
              label: "Name of the Applicant", textController: nameController),
          UserTextInputField(
              label: 'Father/Mother/Husband Name',
              textController: fatherMotherHusbandController),
          UserDropDownField(
              label: "Occupation",
              selectionList: occupationList,
              selectedItem: selectedOccupation,
              setSelectedItem: setSelectedDropDownOption),
          UserTextInputField(
              label: 'Nominee Name', textController: nomineeNameController),
          UserDropDownField(
              label: "Relationship with nominee",
              selectionList: nomineeList,
              selectedItem: selectedNominee,
              setSelectedItem: setSelectedDropDownOption),
          UserTextInputField(
              label: 'Address', textController: addressController),
          UserTextInputField(label: 'Age', textController: ageController),
          UserTextInputField(
              label: 'Mobile Number', textController: mobileNumberController),
          UserTextInputField(
              label: 'Email Address', textController: mailController),
          UserTextInputField(
              label: 'Alternate Mobile',
              textController: alternateMobileController),
          UserTextInputField(
              label: 'Application ID Proof',
              textController: applicantIDProofController),
          UserTextInputField(
              label: 'Nominee ID Proof',
              textController: nomineeIDProofController),

          Padding(
            padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
            child: ElevatedButton(
              onPressed: submitData,
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15)),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
