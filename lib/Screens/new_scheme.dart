import 'package:flutter/material.dart';
import 'package:hassanjewellers/Widgets/confirm_details.dart';
import 'package:hassanjewellers/Widgets/drop_down_field.dart';
import 'package:hassanjewellers/Widgets/user_text_input_field.dart';
import 'package:hassanjewellers/Screens/payment_successfull.dart';
import 'package:hassanjewellers/Helpers/animated_route.dart';
import 'package:hassanjewellers/Helpers/validate_fields.dart';
import 'package:hassanjewellers/Services/firebase_services/addNewScheme.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  TextEditingController mobileNumber = TextEditingController();

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

  late WebViewController webViewController;

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
      body: CustomScrollView(
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Join New Scheme",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Form Content
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          UserDropDownField(
                            key: const Key("Field1"),
                            label: "Installment Amount",
                            selectionList: monthlyInstallmentAmounts,
                            selectedItem: monthlySelectedAmount,
                            setSelectedItem: setSelectedDropDownOption,
                          ),
                          UserTextInputField(
                            label: "Name of the Applicant",
                            textController: nameController,
                            validationCriteria: validateName,
                          ),
                          UserTextInputField(
                            label: 'Guardian Name',
                            textController: fatherMotherHusbandController,
                            validationCriteria: validateGuardianName,
                          ),
                          UserDropDownField(
                            label: "Occupation",
                            selectionList: occupationList,
                            selectedItem: selectedOccupation,
                            setSelectedItem: setSelectedDropDownOption,
                          ),
                          UserTextInputField(
                            label: 'Nominee Name',
                            textController: nomineeNameController,
                            validationCriteria: validateNomineeName,
                          ),
                          UserDropDownField(
                            label: "Relationship with nominee",
                            selectionList: nomineeList,
                            selectedItem: selectedNominee,
                            setSelectedItem: setSelectedDropDownOption,
                          ),
                          UserTextInputField(
                            label: 'Address',
                            textController: addressController,
                            validationCriteria: validateAddress,
                          ),
                          UserTextInputField(
                            label: 'Age',
                            textController: ageController,
                            validationCriteria: validateAge,
                            isNumber: true,
                          ),
                          UserTextInputField(
                            label: 'Mobile Number',
                            isNumber: true,
                            textController: mobileNumber,
                            validationCriteria: validateAlternativeMobile,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  FocusScope.of(context).unfocus();

                                  if (_formKey.currentState?.validate() ?? false) {
                                    final confirmed = await showConfirmationDialog(
                                      context,
                                      monthlySelectedAmount,
                                      nameController.text,
                                      fatherMotherHusbandController.text,
                                      selectedOccupation,
                                      nomineeNameController.text,
                                      selectedNominee,
                                      addressController.text,
                                      ageController.text,
                                      mobileNumber.text,
                                    );

                                    if (confirmed != null && confirmed) {
                                      webViewController = WebViewController()
                                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                        ..setBackgroundColor(Colors.white)
                                        ..loadRequest(Uri.parse(
                                            "http://spt.uvm.mybluehostin.me/pages/terms/"));

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Container(
                                              padding: const EdgeInsets.all(24),
                                              height: MediaQuery.of(context).size.height * 0.8,
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(16),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.description_outlined,
                                                      size: 32,
                                                      color: Theme.of(context).primaryColor,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Text(
                                                    'Terms and Conditions',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Expanded(
                                                    child: WebViewWidget(
                                                      controller: webViewController,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        style: TextButton.styleFrom(
                                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                        ),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: Colors.grey[600],
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          addNewScheme(
                                                            nameController.text,
                                                            monthlySelectedAmount,
                                                            fatherMotherHusbandController.text,
                                                            selectedOccupation,
                                                            nomineeNameController.text,
                                                            selectedNominee,
                                                            addressController.text,
                                                            ageController.text,
                                                          ).then((value) {}).whenComplete(
                                                            () => Navigator.of(context).push(
                                                              animatedRoute(
                                                                const PaymentSuccessfull(),
                                                                context,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: Theme.of(context).primaryColor,
                                                          foregroundColor: Colors.white,
                                                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                        ),
                                                        child: const Text(
                                                          'I Agree',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w500,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
