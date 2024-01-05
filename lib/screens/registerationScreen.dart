import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rider_app/screens/mainScreen.dart';

import '../loginScreen.dart';
import '../widgets/progressDiolog.dart';

class RegistrationScreen extends StatefulWidget {
  static const String idScreen = "register";

  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  TextEditingController nameTextEditingController = TextEditingController();

  TextEditingController emailTextEditingController = TextEditingController();

  TextEditingController phoneTextEditingController = TextEditingController();

  TextEditingController passwordTextEditingController = TextEditingController();

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog("Please wait...");
        }
    );
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
          email: emailTextEditingController.text,
          password: passwordTextEditingController.text)
          .catchError((errMsg) {
        Navigator.pop(context);
        displayToastMessage("Error: $errMsg", context);
      });

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Save user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'name': nameTextEditingController.text.trim(),
          'email': emailTextEditingController.text.trim(),
          'phone': phoneTextEditingController.text.trim(),
        });

        displayToastMessage(
            "Your account has been created.", context);

        Navigator.pushNamed(
          context,
          MainScreen.idScreen,
        );
      }
    } catch (e) {
      Navigator.pop(context);
      displayToastMessage("New user account has not been created", context);
      // Handle registration errors, e.g., show an error message to the user.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30.0),
            const Image(
              image: AssetImage("images/lock.png"),
              width: 390.0,
              height: 250.0,
              alignment: Alignment.center,
            ),
            const SizedBox(height: 1.0),
            const Text(
              'Register as a Rider',
              style: TextStyle(
                fontSize: 24.0,
                fontFamily: "Brand bold",
              ),
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const SizedBox(height: 1.0),
                  TextField(
                    controller: nameTextEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: "Brand-Regular",
                      ),
                      hintText: "Enter your name",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: "Brand-Regular",
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: emailTextEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: "Brand-Regular",
                      ),
                      hintText: "Enter your email",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: "Brand-Regular",
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.white,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  TextField(
                    controller: phoneTextEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      labelStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: "Brand-Regular",
                      ),
                      hintText: "Enter your phone number",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: "Brand-Regular",
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),

                  const SizedBox(height: 10.0),
                  TextField(
                    controller: passwordTextEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: const TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                        fontFamily: "Brand-Regular",
                      ),
                      hintText: "Enter your password",
                      hintStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                        fontFamily: "Brand-Regular",
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white, width: 1.0),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.white,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14.0,
                    ),
                  ),

                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all(10.0),
                    ),
                    onPressed: () {
                      if (nameTextEditingController.text.length < 3) {
                        displayToastMessage("Name must be at least 3 characters", context);
                      } else if (!isValidEmail(emailTextEditingController.text)) {
                        displayToastMessage("Email address is not valid", context);
                      } else if (phoneTextEditingController.text.isEmpty) {
                        displayToastMessage("Phone number is mandatory", context);
                      } else if (passwordTextEditingController.text.length < 6) {
                        displayToastMessage("Password must be at least 6 characters", context);
                      } else {
                        registerNewUser(context);
                      }
                    },
                    child: const SizedBox(
                      height: 50.0,
                      child: Center(
                        child: Text(
                          "Create Account",
                          style: TextStyle(fontSize: 18.0, fontFamily: "Brand bold"),
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  LoginScreen.idScreen,
                );
              },
              child: const Text(
                "Already have an account? Login here",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }


  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  bool isValidEmail(String email) {
    // Use a regular expression for email validation
    final RegExp emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }
}
