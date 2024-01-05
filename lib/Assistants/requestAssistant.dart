import 'dart:convert'; // Import this for JSON decoding

import 'package:http/http.dart' as http;

class RequestAssistant {
  static Future<dynamic> getRequest(String url) async {
    Uri uri = Uri.parse(url);
    http.Response response = await http.get(uri);

    if (response.statusCode == 200) {
      String jsonData = response.body;
      var decodedData = json.decode(jsonData); // Correct JSON decoding

      return decodedData;
    } else {
      // Handle error cases here, e.g., throw an exception or return an error object
      throw Exception('Failed to load data. Status code: ${response.statusCode}');
    }
  }
}
