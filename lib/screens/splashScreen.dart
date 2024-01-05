import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:rider_app/screens/slider.dart';
import '../loginScreen.dart';

class SplashScreen extends StatelessWidget {
  static const String idScreen = "splash";

  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[200],
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedSplashScreen(
              splash: const StylishLogoWidget(),
              backgroundColor: Colors.deepPurple,
              duration: 3000,
              nextScreen: const SliderScreen(),
            ),
          ),
          const Center( // Updated to Center widget
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Taxi App',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Brand Bold',
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Rider App",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontFamily: 'Brand Regular',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StylishLogoWidget extends StatelessWidget {
  const StylishLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
      )
        )// Add your logo or other content here
    );
  }
}