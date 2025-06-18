import 'package:flutter/material.dart';
import 'package:soricc/screens/login.dart';
import 'dart:async';



class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Navigate to the StartScreen after 5 seconds
    Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF4B2C83), // Purple background color
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment:
            CrossAxisAlignment.center, // Center all content horizontally
        children: [
          Spacer(), // Pushes content down
          // Clock icon
          Icon(
            Icons.access_time,
            size: 100.0,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          // Centered 'Employee Working Hours Justification' text
          Padding(
            padding: EdgeInsets.only(left: 35),
            child: Text(
              'Employee Working Hours Justification',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign:
                  TextAlign.center, // Ensures the text aligns in the center
            ),
          ),
          Spacer(), // Creates space between this text and the bottom text
          // 'Powered by Soric' text positioned at the bottom
          Padding(
            padding: EdgeInsets.only(
                bottom: 30.0), // Add some space from the bottom edge
            child: Text(
              'Powered By Soriic',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
              textAlign:
                  TextAlign.center, // Ensures bottom text is also centered
            ),
          ),
        ],
      ),
    );
  }
}
