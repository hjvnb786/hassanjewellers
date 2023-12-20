import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/drop_down_field.dart';
import 'package:hassanjewellers/Components/user_text_input_field.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';

class NewScheme extends StatefulWidget {
  const NewScheme({super.key});

  @override
  State<NewScheme> createState() => _NewSchemeState();
}

class _NewSchemeState extends State<NewScheme> {
  final _formKey = GlobalKey<FormState>();

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

  String? validateFName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter f some value";
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter some value";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join New Scheme"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            UserDropDownField(
                label: "Installment Amount",
                selectionList: monthlyInstallmentAmounts,
                selectedItem: monthlySelectedAmount,
                setSelectedItem: setSelectedDropDownOption),
            UserTextInputField(
                label: "Name of the Applicant",
                textController: nameController,
                validationCriteria: validateFName),
            UserTextInputField(
                label: 'Guardian Name',
                textController: fatherMotherHusbandController,
                validationCriteria: validateFName),
            UserDropDownField(
                label: "Occupation",
                selectionList: occupationList,
                selectedItem: selectedOccupation,
                setSelectedItem: setSelectedDropDownOption),
            UserTextInputField(
                label: 'Nominee Name',
                textController: nomineeNameController,
                validationCriteria: validateName),
            UserDropDownField(
                label: "Relationship with nominee",
                selectionList: nomineeList,
                selectedItem: selectedNominee,
                setSelectedItem: setSelectedDropDownOption),
            UserTextInputField(
                label: 'Address',
                textController: addressController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Age',
                textController: ageController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Mobile Number',
                textController: mobileNumberController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Email Address',
                textController: mailController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Alternate Mobile',
                textController: alternateMobileController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Application ID Proof',
                textController: applicantIDProofController,
                validationCriteria: validateName),
            UserTextInputField(
                label: 'Nominee ID Proof',
                textController: nomineeIDProofController,
                validationCriteria: validateName),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    addNewScheme(
                            nameController.text,
                            monthlySelectedAmount,
                            fatherMotherHusbandController.text,
                            selectedOccupation,
                            nomineeNameController.text,
                            selectedNominee,
                            addressController.text,
                            ageController.text)
                        .then((value) {
                      if (kDebugMode) {
                        print("we did it");
                      }
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
