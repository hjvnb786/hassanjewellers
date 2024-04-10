import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hassanjewellers/Components/confirm_details.dart';
import 'package:hassanjewellers/Components/drop_down_field.dart';
import 'package:hassanjewellers/Components/user_text_input_field.dart';
import 'package:hassanjewellers/Utils/Helpers/validate_fields.dart';
import 'package:hassanjewellers/Utils/Services/firebase_service.dart';

class NewScheme extends StatefulWidget {
  const NewScheme({super.key});

  @override
  State<NewScheme> createState() => _NewSchemeState();
}

class _NewSchemeState extends State<NewScheme> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController fatherMotherHusbandController = TextEditingController();
  TextEditingController nomineeNameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController alternateMobileController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Join New Scheme"),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              UserDropDownField(
                  key: const Key("Field1"),
                  label: "Installment Amount",
                  selectionList: monthlyInstallmentAmounts,
                  selectedItem: monthlySelectedAmount,
                  setSelectedItem: setSelectedDropDownOption),
              UserTextInputField(
                  label: "Name of the Applicant",
                  textController: nameController,
                  validationCriteria: validateName),
              UserTextInputField(
                  label: 'Guardian Name',
                  textController: fatherMotherHusbandController,
                  validationCriteria: validateGuardianName),
              UserDropDownField(
                  label: "Occupation",
                  selectionList: occupationList,
                  selectedItem: selectedOccupation,
                  setSelectedItem: setSelectedDropDownOption),
              UserTextInputField(
                  label: 'Nominee Name',
                  textController: nomineeNameController,
                  validationCriteria: validateNomineeName),
              UserDropDownField(
                  label: "Relationship with nominee",
                  selectionList: nomineeList,
                  selectedItem: selectedNominee,
                  setSelectedItem: setSelectedDropDownOption),
              UserTextInputField(
                  label: 'Address',
                  textController: addressController,
                  validationCriteria: validateAddress),
              UserTextInputField(
                label: 'Age',
                textController: ageController,
                validationCriteria: validateAge,
                isNumber: true,
              ),
              UserTextInputField(
                  label: 'Alternate Mobile',
                  isNumber: true,
                  textController: alternateMobileController,
                  validationCriteria: validateAlternativeMobile),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, right: 20, left: 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {

                      if (_formKey.currentState?.validate() ?? false) {

                        final confirmed = await showConfirmationDialog(
                          context,
                          nameController.text,
                          fatherMotherHusbandController.text,
                          nomineeNameController.text,
                          addressController.text,
                          ageController.text,
                          alternateMobileController.text,
                        );

                        if (confirmed != null && confirmed) {
                          // User confirmed, you can now proceed with submitting the data
                          // submitData();


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
                          print('Data submitted');
                        } else {
                          // User canceled, handle accordingly
                          print('User canceled');
                        }

                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text('Submit'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



