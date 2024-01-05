import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:rider_app/DataHandler/appData.dart';
import 'package:rider_app/screens/mainScreen.dart';
import 'package:rider_app/screens/registerationScreen.dart';
import 'package:rider_app/screens/splashScreen.dart';

import 'firebase_options.dart';
import 'loginScreen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // Initialize Firebase
  runApp(MyApp());
  // Fluttertoast.showToast(msg: "");
}

// Reference to the 'users' collection in Firestore
CollectionReference usersRef = FirebaseFirestore.instance.collection("users");

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:  (context) =>AppData(),
      child: MaterialApp(
        title: 'Taxi Rider App',
        theme: ThemeData(
          fontFamily: "Brand Bold",
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        initialRoute:SplashScreen.idScreen  ,
        routes: {
          RegistrationScreen.idScreen: (context) => const RegistrationScreen(),
          LoginScreen.idScreen: (context) => LoginScreen(),
          MainScreen.idScreen: (context) =>  MainScreen(userId: 'name', userName: '',),
          SplashScreen.idScreen:(context)=>const SplashScreen(),
        },
      ),
    );
  }
}

// Example of adding a user to Firestore
void addUserToFirestore(String userId, String userName) async {
  await usersRef.doc(userId).set({
    'username': userName,
    // Add other user details as needed
  });
}
