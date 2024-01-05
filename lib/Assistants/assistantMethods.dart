import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'dart:convert';

import 'package:rider_app/Models/address.dart'; // Make sure this import is correct

class AssistantMethod {
  static Future<String> searchCoordinateAddress(Position position, context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String apiKey = "AIzaSyDzGSo__7sAQsoE2RMrqwo3iFbXF6yK5XI"; // Replace with your API key
    String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey";

    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        print("Geocoding API response: $data"); // Add this line

        st1 = data['results'][0]['address_components'][0]["long_name"];
        st2 = data['results'][0]['address_components'][1]["long_name"];
        st3 = data['results'][0]['address_components'][5]["long_name"];
        st4 = data['results'][0]['address_components'][6]["long_name"];
        placeAddress = "$st1, $st2, $st3, $st4";

        Address userPickUpAddress = Address(
          placeFormattedAddress: placeAddress,
          placeName: st1 + ", " + st2,
          placeId: st3,
          latitude: position.latitude,
          longitude: position.longitude,
        );

        Provider.of<AppData>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);
      } else {
        throw Exception(
            'Failed to load address. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch address: $e');
    }

    return placeAddress;
  }
}