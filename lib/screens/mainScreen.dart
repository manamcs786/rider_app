import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:geolocator/geolocator.dart';

import 'drawer_widget.dart';


enum SelectedVehicle {
  Bike,
  MiniCar,
  Comfort,
  RideAC
}


class MainScreen extends StatefulWidget {
  static String idScreen = "mainScreen";
  final String userId;
  final String userName;

  const MainScreen({Key? key, required this.userId,required this.userName}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Color myColor = const Color(0xFF202D40);
  Color textColor = const Color(0xFFFFFFFF);


  double calculateDistanceInMeters(LatLng pickup, LatLng drop) {
    double distanceInMeters = Geolocator.distanceBetween(
      pickup.latitude,
      pickup.longitude,
      drop.latitude,
      drop.longitude,
    );
    return distanceInMeters;
  }

  Color getVehicleBackgroundColor(SelectedVehicle vehicle) {
    return (selectedVehicle == vehicle) ? Colors.yellowAccent : Colors.white;
  }
  SelectedVehicle? selectedVehicle;
  int calculateBikeFare(double distanceInMeters) {
    return (distanceInMeters * 0.10).ceil(); // Rs 0.10 per meter
  }

  int calculateMiniCar(double distanceInMeters) {
    return (distanceInMeters * 0.20).ceil(); // Rs 0.20 per meter
  }

  int calculateComfort(double distanceInMeters) {
    return (distanceInMeters * 0.30).ceil(); // Rs 0.30 per meter
  }

  int calculateRideAC(double distanceInMeters) {
    return (distanceInMeters * 0.40).ceil(); // Rs 0.20 per meter
  }




  late GoogleMapController? mapController;


  late Marker _userLocationMarker = Marker(
    markerId: const MarkerId('userLocation'),


    position: const LatLng(40.7128, -74.0060),
    // Initial position (New York City coordinates)
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
  );

  late Marker _dropLocationMarker = Marker(
    infoWindow: const InfoWindow(title: "Your drop location"),
    markerId: const MarkerId('dropLocation'),
    position: const LatLng(40.7128, -73.9352),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    onTap: () async {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _dropLocationMarker.position.latitude,
        _dropLocationMarker.position.longitude,
        localeIdentifier: 'ur_PK',
      );
      String streetName = placemarks.isNotEmpty ? placemarks[0].street
          .toString() : 'Unknown';
      String cityName = placemarks.isNotEmpty ? placemarks[0].locality
          .toString() : 'Unknown';

      setState(() {
        // Update the dropController text with city and street name
        dropController.text = "$cityName, $streetName";
      });
    },
  );
  late Polyline _polyline = const Polyline(
    polylineId: PolylineId('polyline'),
    color: Colors.blue,
    points: [], // Empty list initially
    width: 3,
  );
  TextEditingController pickupController = TextEditingController();
  TextEditingController dropController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  String? distanceText;
  String? fareText;


  bool isContainerVisible = true;
  bool isContainerExpanded = false;
  String userName = 'Profile name'; // Default value
  String userEmail = 'No email available'; // Default value
  String userPhone = 'No phone number';

  @override
  void initState() {
    super.initState();
    userName = widget.userName;

    selectedSearchOption = 'Pickup';

    _userLocationMarker = Marker(
      markerId: const MarkerId('userLocation'),

      position: const LatLng(40.7128, -74.0060),
      infoWindow: const InfoWindow(
        title: 'Your current location',

      ), // Initial position (New York City coordinates)
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    // Fetch user info only if userId is not empty
    if (widget.userId.isNotEmpty) {
      getUserInfo();
    }
    _getCurrentLocation();
    // Fetch and display the current location
  }

  Future<void> _getCurrentLocation() async {
    LocationManager.Location location = LocationManager.Location();
    bool _serviceEnabled;
    LocationManager.PermissionStatus _permissionGranted;
    LocationManager.LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == LocationManager.PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != LocationManager.PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await location.getLocation();
    LatLng currentLocation = LatLng(
        _locationData.latitude!, _locationData.longitude!);
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentLocation.latitude,
      currentLocation.longitude,
      localeIdentifier: 'ur_PK',
    );
    String streetName = placemarks.isNotEmpty
        ? placemarks[0].street.toString()
        : 'Unknown';
    String cityName = placemarks.isNotEmpty
        ? placemarks[0].locality.toString()
        : 'Unknown';

    setState(() {
      _userLocationMarker = _userLocationMarker.copyWith(
        positionParam: currentLocation,
      );
      pickupController.text = streetName;
      // Assuming you have a city field to display the city name
      cityController.text = cityName;
    });

    mapController?.animateCamera(CameraUpdate.newLatLng(currentLocation));
  }

  void getUserInfo() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userInfo = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userInfo.exists) {
        setState(() {
          userName = userInfo['name'] ?? 'Profile name';
          // Other user information retrieval if needed
        });
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error fetching user info: $e');
    }
  }



  void _updateDropLocation(LatLng position) async {
    double distanceInKm = 0.0;
    double fare = 0.0;

    double distanceInMeters = await Geolocator.distanceBetween(
      _userLocationMarker.position.latitude,
      _userLocationMarker.position.longitude,
      position.latitude,
      position.longitude,
    );

    distanceInKm = distanceInMeters / 1000;

    if (selectedVehicle == SelectedVehicle.Bike) {
      fare = calculateBikeFare(distanceInMeters).toDouble();
    } else if (selectedVehicle == SelectedVehicle.MiniCar) {
      fare = calculateMiniCar(distanceInMeters).toDouble();
    } else if (selectedVehicle == SelectedVehicle.Comfort) {
      fare = calculateComfort(distanceInMeters).toDouble(); // Use existing method
    } else if (selectedVehicle == SelectedVehicle.RideAC) {
      fare = calculateRideAC(distanceInMeters).toDouble(); // Use existing method
    }



    setState(() {
      _dropLocationMarker = _dropLocationMarker.copyWith(
        positionParam: position,
      );

      _polyline = Polyline(
        polylineId: const PolylineId('polyline'),
        color: Colors.deepPurple,
        points: [
          _userLocationMarker.position,
          position,
        ],
        width: 3,
      );

      distanceText = 'Distance: ${distanceInKm.toStringAsFixed(2)} km';
      fareText = (fare > 0) ? 'Rs ${fare.toStringAsFixed(0)}' : '';
    });
  }



  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  late String searchAddr;
  late String selectedSearchOption;
  void _showLocationSearch() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  // Handle search text changes and update the UI accordingly
                  // Update the text field with the selected location
                  // For example:
                  // pickupController.text = value;
                },
                decoration: const InputDecoration(
                  hintText: "Search for a location",
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              // Add your map or list of locations here for the user to choose from
              // Update the _dropLocationMarker when a location is selected
              // ...
            ],
          ),
        );
      },
    );
  }
  Widget buildVehicleOption(SelectedVehicle vehicle, String imageAsset, Function() onPressed) {
    Color? backgroundColor;
    Color textColor = Colors.white; // Set default text color

    // Check if the current vehicle matches the selected vehicle
    bool isSelected = selectedVehicle == vehicle;

    // Assign different background colors based on the selection
    backgroundColor = isSelected ? Colors.green : myColor;

    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 8.0), // Add margin between options
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10), // Adjust border radius as needed
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 60,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Image.asset(
                  imageAsset,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 5,),
            Text(
              vehicle.toString().split('.').last,
              style: TextStyle(color: textColor,fontFamily: "Brand-Regular"),
              // Apply text color here
            ),
            // Display vehicle type
          ],
        ),
        
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        SystemNavigator.pop(); // This line exits the app
        return false; // Return false to prevent default behavior
      },
      child: Scaffold(
        key: scaffoldKey,
        drawer: Drawer(
          // Using the built-in Drawer widget
          child: DrawerWidget(userName: 'Manam Hussain'), // Replace 'John Doe' with the actual username
        ),
        body: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 40,),
              child: GoogleMap(

                myLocationEnabled: true,



                onMapCreated: (controller) {
                  setState(() {
                    mapController = controller;


                  });
                },



                initialCameraPosition: const CameraPosition(
                  target: LatLng(40.7128, -74.0060),
                  zoom: 14.0,
                ),

                markers: {
                  _userLocationMarker,
                  _dropLocationMarker,
                },
                polylines: {
                  _polyline,
                },
                onTap: (LatLng position) {
                  _updateDropLocation(position);
                },
                
              ),
            ),



            Positioned(
              top: 45.0,
              left: 22.0,

              child: GestureDetector(
                onTap: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 6.0,
                        spreadRadius: 0.5,
                        offset: Offset(
                          0.7,
                          0.7,
                        ),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.black,
                    radius: 22.0,
                    child: Image.asset(
                      'images/sidemenu.png', // Replace with the path to your custom menu icon
                      width: 50.0, // Adjust width as needed
                      height: 50.0, // Adjust height as needed
                      color: Colors.white, // Optionally, you can set the color of the icon
                    ),
                  ),
                ),
              ),
            ),




              Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,

              child: GestureDetector(
                onTap: () {
                  setState(() {
                    if (isContainerExpanded) {
                      isContainerVisible = !isContainerVisible;
                    }
                    isContainerExpanded = !isContainerExpanded;
                  });
                },


                child: AnimatedContainer(


                  duration: const Duration(milliseconds: 300),
                  height: isContainerExpanded ? 490.0 : 100.0,
                  decoration:  BoxDecoration(
                    color: myColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18.0),
                      topRight: Radius.circular(18.0),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 16.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 18.0,
                    ),
                    child: SingleChildScrollView(

                      child:Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Please Select Ride",style: TextStyle(fontSize: 15,color: Colors.white,fontWeight: FontWeight.bold),

                          ),
                          const SizedBox(height: 10,),


                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                buildVehicleOption(
                                  SelectedVehicle.Bike,
                                  'images/green.png',
                                      () {
                                    setState(() {
                                      selectedVehicle = SelectedVehicle.Bike;
                                      double distanceInMeters = calculateDistanceInMeters(
                                        _userLocationMarker.position,
                                        _dropLocationMarker.position,
                                      );
                                      int fare = calculateBikeFare(distanceInMeters);
                                      fareText = 'Rs $fare';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8,),
                                buildVehicleOption(
                                  SelectedVehicle.MiniCar,
                                  'images/car2.png',
                                      () {
                                    setState(() {
                                      selectedVehicle = SelectedVehicle.MiniCar;
                                      double distanceInMeters = calculateDistanceInMeters(
                                        _userLocationMarker.position,
                                        _dropLocationMarker.position,
                                      );
                                      int fare = calculateMiniCar(distanceInMeters);
                                      fareText = 'Rs $fare';
                                    });
                                  },
                                ),

                                const SizedBox(width: 8,),
                                buildVehicleOption(
                                  SelectedVehicle.Comfort,
                                  'images/car1.png',
                                      () {
                                    setState(() {
                                      selectedVehicle = SelectedVehicle.Comfort;
                                      double distanceInMeters = calculateDistanceInMeters(
                                        _userLocationMarker.position,
                                        _dropLocationMarker.position,
                                      );
                                      int fare = calculateComfort(distanceInMeters);
                                      fareText = 'Rs $fare';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8,),
                                buildVehicleOption(
                                  SelectedVehicle.RideAC,
                                  'images/car3.png',
                                      () {
                                    setState(() {
                                      selectedVehicle = SelectedVehicle.RideAC;
                                      double distanceInMeters = calculateDistanceInMeters(
                                        _userLocationMarker.position,
                                        _dropLocationMarker.position,
                                      );
                                      int fare = calculateRideAC(distanceInMeters);
                                      fareText = 'Rs $fare';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20,),
                          TextField(
                            controller: pickupController,
                            onTap: () {

                            },
                            decoration: InputDecoration(
                              hintText: "Enter Pickup Location",
                              hintStyle: const TextStyle(color: Colors.white),
                              prefixIcon: IconButton(
                                icon: const Icon(Icons.location_on, color: Colors.green),
                                onPressed: () {

                                },
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white), // Set default color here
                              ),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),


                          const SizedBox(height: 20,),
                          TextField(
                            controller: dropController,
                            decoration: InputDecoration(
                                hintText: "Enter Drop Location",
                                hintStyle: const TextStyle(color: Colors.white),
                                prefixIcon: IconButton(
                                  icon: const Icon(Icons.location_pin,color: Colors.orangeAccent,),
                                  onPressed: (){
                                    String dropLocation = dropController.text;

                                  },
                                ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)
                              )
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(height: 1,),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 07.0, horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 1),

                                const Icon(Icons.directions_walk,color: Colors.white,),
                                Center(
                                  child: Text(

                                    distanceText ?? '',
                                    style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontFamily: "Brand-Regular",
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ),


                          const SizedBox(height: 1), // Add some space between the two cards
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 07.0, horizontal: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const SizedBox(height: 1),
                                Center(
                                  child: Text(
                                    fareText ?? '',
                                    style: const TextStyle(
                                      fontSize: 40.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                      fontFamily: "Brand-Regular",
                                      
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),




                          const SizedBox(height: 10,),
                          ElevatedButton(
                            onPressed: () {},
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.green),

                              minimumSize: MaterialStateProperty.all<Size>(
                                const Size(double.infinity, 50.0), // Set the minimum width and desired height
                              ),

                            ),
                            child: const Text("Find a Driver",style: TextStyle(fontSize: 20,fontFamily: "Brand-Regular"),),
                          ),
                          //
                        ],

                      ),





                    ),
                  ),

                ),


              ),
            ),

          ],
        ),
      ),
    );
  }
}







































































// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:rider_app/DataHandler/appData.dart';
// import 'package:rider_app/Models/address.dart';
// import 'package:rider_app/Assistants/assistantMethods.dart';
// import 'package:rider_app/widgets/Divider.dart';
//
// class MainScreen extends StatefulWidget {
//   static const String idScreen = "mainScreen";
//
//   const MainScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   Completer<GoogleMapController> _controllerGoogleMap = Completer();
//   GoogleMapController? newGoogleMapController;
//
//   GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//
//   Position? currentPosition; // Initialize to avoid non-nullable error
//   var geoLocator = Geolocator();
//
//   double bottomPaddingOfMap = 0;
//
//   @override
//   @override
//   void initState() {
//     super.initState();
//     locatePosition();
//   }
//
//   void locatePosition() async {
//     try {
//       bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!isLocationServiceEnabled) {
//         return;
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
//           return;
//         }
//       }
//
//       Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//
//       setState(() {
//         currentPosition = position;
//       });
//
//       if (currentPosition != null) {
//         LatLng latLngPosition = LatLng(position.latitude, position.longitude);
//
//         CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);
//         newGoogleMapController?.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//
//         String address = await AssistantMethod.searchCoordinateAddress(position, context);
//
//         print("This is your Address ::" + address);
//
//         // Replace the hardcoded values with the actual values
//         Address pickUpAddress = Address(
//           placeFormattedAddress: address,
//           placeName: "YourPlaceName",
//           placeId: "YourPlaceId",
//           latitude: position.latitude,
//           longitude: position.longitude,
//         );
//
//         Provider.of<AppData>(context, listen: false).updatePickUpLocationAddress(pickUpAddress);
//       }
//     } catch (e) {
//       print("Error locating position: $e");
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     // Check if pickUpLocation is null
//     if (Provider.of<AppData>(context).pickUpLocation == null) {
//       // Provide a loading state or alternative widget
//       return Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }
//
//     // Access pickUpLocation after ensuring it's not null
//     String pickUpAddress = Provider.of<AppData>(context).pickUpLocation!.placeFormattedAddress;
//
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Text('Welcome'),
//       ),
//       drawer: Container(
//         color: Colors.white,
//         width: 255.0,
//         child: Drawer(
//           child: ListView(
//             children: [
//               // Drawer header
//               Container(
//                 height: 105,
//                 child: DrawerHeader(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     children: [
//                       Image.asset("images/user_icon.png", height: 65.0, width: 65.0,),
//                       SizedBox(width: 16.0,),
//                       Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("Profile name", style: TextStyle(
//                             fontSize: 16.0,
//                             fontFamily: "Brand Bold",
//                           ),),
//                           SizedBox(height: 6.0,),
//                           Text("Visit Profile")
//                         ],
//                       )
//                     ],
//                   ),
//                 ),
//               ),
//               DividerWidget(),
//               SizedBox(height: 12.0,),
//               // Drawer body controller
//               ListTile(
//                 leading: Icon(Icons.history),
//                 title: Text("History", style: TextStyle(
//                   fontSize: 15.0,
//                 ),),
//               ),
//               ListTile(
//                 leading: Icon(Icons.person),
//                 title: Text("Visit Profile", style: TextStyle(
//                   fontSize: 15.0,
//                 ),),
//               ),
//               ListTile(
//                 leading: Icon(Icons.info),
//                 title: Text("About", style: TextStyle(
//                   fontSize: 15.0,
//                 ),),
//               ),
//             ],
//           ),
//         ),
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
//             mapType: MapType.normal,
//             myLocationButtonEnabled: true,
//             initialCameraPosition: currentPosition != null
//                 ? CameraPosition(target: LatLng(currentPosition!.latitude, currentPosition!.longitude), zoom: 14)
//                 : CameraPosition(
//               target: LatLng(37.42796133580664, -122.085749655962),
//               zoom: 14.4746,
//             ),
//             myLocationEnabled: true,
//             zoomGesturesEnabled: true,
//             zoomControlsEnabled: true,
//             onMapCreated: (GoogleMapController controller) {
//               _controllerGoogleMap.complete(controller);
//               newGoogleMapController = controller;
//
//               setState(() {
//                 bottomPaddingOfMap = 300.0;
//               });
//             },
//           ),
//           Positioned(
//             top: 45.0,
//             left: 22.0,
//             child: GestureDetector(
//               onTap: () {
//                 scaffoldKey.currentState?.openDrawer();
//               },
//               child: Container(
//                 decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(22.0),
//                     boxShadow: [
//                       BoxShadow(
//                           color: Colors.black,
//                           blurRadius: 6.0,
//                           spreadRadius: 0.5,
//                           offset: Offset(
//                             0.7,
//                             0.7,
//                           )
//                       )
//                     ]
//                 ),
//                 child: CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(Icons.menu, color: Colors.black,),
//                   radius: 20.0,
//                 ),
//               ),
//             ),
//           ),
//           Positioned(
//             left: 0.0,
//             right: 0.0,
//             bottom: 0.0,
//             child: Container(
//               height: 300.0,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(topLeft: Radius.circular(18.0), topRight: Radius.circular(18.0)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black,
//                     blurRadius: 16.0,
//                     spreadRadius: 0.5,
//                     offset: Offset(0.7, 0.7),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: 6.0),
//                     Text(
//                       "Hi there,",
//                       style: TextStyle(
//                         fontSize: 12.0,
//                       ),
//                     ),
//                     Text(
//                       "Where to?,",
//                       style: TextStyle(
//                         fontSize: 20.0,
//                         fontFamily: "Brand Bold",
//                       ),
//                     ),
//                     SizedBox(height: 20.0),
//                     Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(5.0),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black54,
//                             blurRadius: 6.0,
//                             spreadRadius: 0.5,
//                             offset: Offset(0.7, 0.7),
//                           ),
//                         ],
//                       ),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Row(
//                           children: [
//                             Icon(Icons.search, color: Colors.indigoAccent,),
//                             SizedBox(width: 10.0,),
//                             Text("Search Drop Off ")
//                           ],
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 24.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.home, color: Colors.grey,),
//                         SizedBox(width: 12.0,),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                                 Provider.of<AppData>(context).pickUpLocation !=null
//                                     ?Provider.of<AppData>(context).pickUpLocation!.placeName
//                                     : "Add Home"
//                             ),
//                             SizedBox(height: 4.0,),
//                             Text("Your living home address", style: TextStyle(
//                               color: Colors.black45,
//                               fontSize: 12.0,
//                             ),)
//                           ],
//                         )
//                       ],
//                     ),
//                     SizedBox(height: 10.0,),
//                     DividerWidget(),
//                     SizedBox(height: 16.0,),
//                     Row(
//                       children: [
//                         Icon(Icons.work, color: Colors.grey,),
//                         SizedBox(width: 12.0,),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Add Work"),
//                             SizedBox(height: 4.0,),
//                             Text("Your office address", style: TextStyle(
//                               color: Colors.black54,
//                               fontSize: 12.0,
//                             ),)
//                           ],
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
