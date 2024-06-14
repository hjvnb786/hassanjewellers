import 'package:http/http.dart' as http;

void makePaymentRequest() async {
  final url = Uri.parse("https://test.payu.in/_payment");

  // Define the request body
  Map<String, String> requestBody = {
    "key": "WkffIy",
    "txnid": "Dnh8wYimuCRIdv",
    "amount": "10.00",
    "firstname": "PayU User",
    "email": "test@gmail.com",
    "phone": "9876543210",
    "productinfo": "iPhone",
    "pg": "",
    "bankcode": "",
    "surl": "https://apiplayground-response.herokuapp.com/",
    "furl": "https://apiplayground-response.herokuapp.com/",
    "ccnum": "",
    "ccexpmon": "",
    "ccexpyr": "",
    "ccvv": "",
    "ccname": "",
    "txn_s2s_flow": "",
    "hash":
        "cb4b8bda5677dbe80f53735b1d0ec5d48164c3654627369268cf6bf266db994db39108ce2e0868c953e66c172f6b2d78836b253d3463d0cc40d9b6a93118ed56",
  };

  // Make the POST request
  final response = await http.post(
    url,
    body: requestBody,
    headers: {"Content-Type": "application/x-www-form-urlencoded"},
  );

  // Print the status code
  print("Status Code: ${response.statusCode}");

  // Print the response body
  print("Response Body: ${response.body}");
}

void mainPayment() async {
  var url = Uri.parse("https://test.payu.in/_payment");
  var headers = {
    "Accept": "application/json",
    "Content-Type": "application/x-www-form-urlencoded",
  };

  var payload = {
    "key": "JP***g",
    "txnid": "txnid94225030592",
    "amount": "10.00",
    "firstname": "PayU User",
    "email": "test@gmail.com",
    "phone": "9876543210",
    "productinfo": "iPhone",
    "pg": "",
    "bankcode": "",
    "surl": "https://test-payment-middleware.payu.in/simulatorResponse",
    "furl": "https://test-payment-middleware.payu.in/simulatorResponse",
    "hash":
        "613668ecd89823a6502c9a514600a1d21b0cf29d2869578d1f69bdf3065018bbcb244aaef17d3c7215d164b87eb16392f46c1878d55437d006e97610e9e5202f",
  };

  var response = await http.post(url, headers: headers, body: payload);
  print(response.body);
}

