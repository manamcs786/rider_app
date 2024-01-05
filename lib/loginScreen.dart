import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rider_app/screens/mainScreen.dart';
import 'package:rider_app/screens/registerationScreen.dart';
import 'package:rider_app/widgets/progressDiolog.dart';

class LoginScreen extends StatefulWidget {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  static const String idScreen = "login";
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        SystemNavigator.pop(); // This line exits the app
        return false; // Return false to prevent default behavior
      },
      child: Scaffold(
        backgroundColor: Colors.deepOrangeAccent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              const Image(
                image: AssetImage("images/lock.png"),
                width: 390.0,
                height: 250.0,
                alignment: Alignment.center,
              ),
              const SizedBox(height: 1.0),
              const Text(
                'Login as a Rider',
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.white,
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
                      controller: widget.emailTextEditingController,
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
                        suffixIcon: const Icon(
                          Icons.email,
                          color: Colors.white,
                        ),
                      ),
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontFamily: "Brand-Regular",
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    TextField(
                      controller: widget.passwordTextEditingController,
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
                        suffixIcon: const Icon(
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
                        if (!isValidEmail(widget.emailTextEditingController.text)) {
                          displayToastMessage("Email address is not valid", context);
                        } else if (widget.passwordTextEditingController.text.isEmpty) {
                          displayToastMessage("Password is must mandatory", context);
                        } else {
                          LoginAndAuthenticateUser(context);
                        }
                      },
                      child: Container(
                        height: 50.0,
                        child: const Center(
                          child: Text(
                            "Login",
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
                    RegistrationScreen.idScreen,
                  );
                },
                child: const Text(
                  "Do not have an account? Register here",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20,),
              // Add Google login button below the 'Do not have an account?' text
          TextButton(
            onPressed: () {
              // Call the function to handle Google login
              handleGoogleSignIn();
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Login with",
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(width: 8),
                Image.asset(
                  "images/google1.png",
                  width: 24,
                  height: 24,
                ),
              ],
            ),

          )

          ],
          ),
        ),
      ),
    );
  }


  displayToastMessage(String message, BuildContext context) {
    Fluttertoast.showToast(msg: message);
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void LoginAndAuthenticateUser(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ProgressDialog("Please wait...");
      },
    );
    final UserCredential userCredential = await _firebaseAuth
        .signInWithEmailAndPassword(
        email: widget.emailTextEditingController.text,
        password: widget.passwordTextEditingController.text)
        .catchError((errMsg) {
          Navigator.pop(context);
      displayToastMessage("Error: $errMsg", context);
    });

    User? firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      // Save user information to Firestore
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
      });
      Navigator.pushNamed(
        context,
        MainScreen.idScreen,
      );
      displayToastMessage("You are logged in now", context);
    } else {
      Navigator.pop(context);
      _firebaseAuth.signOut();
      displayToastMessage("No record exists for this user, please create a new account", context);
    }
  }

  bool isValidEmail(String email) {
    // Use a regular expression for email validation
    final RegExp emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
    return emailRegex.hasMatch(email);
  }
  void handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await widget._googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the Google Sign-In
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase using the Google credentials
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);

      User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // Save user information to Firestore
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          // Add additional user data if needed
        });

        Navigator.pushNamed(
          context,
          MainScreen.idScreen,
        );

        displayToastMessage("You are logged in now", context);
      } else {
        displayToastMessage("Google Sign-In failed", context);
      }
    } catch (e) {
      displayToastMessage("Error: $e", context);
    }
  }
}


