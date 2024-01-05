import 'package:flutter/material.dart';
import 'package:rider_app/loginScreen.dart';

import '../widgets/progressDiolog.dart';

class SliderScreen extends StatefulWidget {
  static const String idScreen = "slider";
  const SliderScreen({Key? key}) : super(key: key);

  @override
  _SliderScreenState createState() => _SliderScreenState();
}

class _SliderScreenState extends State<SliderScreen> {
  final PageController _controller = PageController(initialPage: 0);
  int _currentPage = 0;

  final List<String> imagePaths = [
    'images/17629208_ThanitJuly_74-removebg-preview.png',
    'images/54444.png',
    'images/3rd-removebg-preview.png',
  ];

  final List<String> titles = [
    'Locate the Destination',
    'Select Your Route',
    'Get Your Taxi',
  ];

  final List<String> subTexts = [
    'Your destination is at your fingertips. Open the app and enter where you want to go.',
    'Get quick access to frequent locations and save them as favorites.',
    'Faster way to book taxi without the hassle of waiting & haggling for price',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrangeAccent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30.0, right: 20.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(LoginScreen.idScreen);
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: imagePaths.length,
                  itemBuilder: (context, index) {
                    return Image.asset(
                      imagePaths[index],
                      fit: BoxFit.contain,
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildPageIndicator(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 80),
          Container(
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titles[_currentPage],
                  style: TextStyle(
                    fontSize: 25,
                    color: Colors.white, // Change text color here
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  subTexts[_currentPage],
                  style: TextStyle(
                    fontFamily: "Brand-Regular",
                    color: Colors.white, // Change text color here
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.green),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                elevation: MaterialStateProperty.all(20.0),
              ),
              onPressed: () {
                if (_currentPage < imagePaths.length - 1) {
                  _controller.animateToPage(
                    _currentPage + 1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease,
                  );
                } else {
                  Navigator.of(context).pushReplacementNamed(LoginScreen.idScreen);
                }
              },
              child: SizedBox(
                height: 50.0,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_currentPage < imagePaths.length - 1 ? 'Next' : 'Start'),
                      SizedBox(width: 5,),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = 0; i < imagePaths.length; i++) {
      list.add(_indicator(i != _currentPage));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: 8.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? Colors.grey : Colors.white,
        border: isActive ? Border.all(color: Colors.grey, width: 1.5) : null,
      ),
    );
  }
}
