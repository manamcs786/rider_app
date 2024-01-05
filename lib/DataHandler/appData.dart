import 'package:flutter/cupertino.dart';
import 'package:rider_app/Models/address.dart';

class AppData with ChangeNotifier {
  Address? _pickUpLocation; // Change to allow null

  Address? get pickUpLocation => _pickUpLocation;

  void updatePickUpLocationAddress(Address pickUpLocation) {
    _pickUpLocation = pickUpLocation;
    notifyListeners();
  }
}
