import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/loginController.dart';
import 'signup.dart';

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    // Start at the top left corner
    path.lineTo(0, size.height * 0.75); // Start from a lower point

    // First wave curve
    var firstControlPoint = Offset(size.width / 4, size.height); // Control point at bottom
    var firstEndPoint = Offset(size.width / 2, size.height * 0.8); // End point lower
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second wave curve
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6); // Control point at mid-height
    var secondEndPoint = Offset(size.width, size.height * 0.75); // End point at lower
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Complete the path
    path.lineTo(size.width, 0); // Close at the top
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class LoginPage extends StatelessWidget {
  final LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height, // Make sure it covers the full screen height
          child: Stack(
            children: [
              // Top wave
              ClipPath(
                clipper: WaveClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.35,
                  color: const Color(0xFFC5B4E3),
                ),
              ),

              // Add logo on the wave
              Positioned(
                top: MediaQuery.of(context).size.height * 0.10,
                left: MediaQuery.of(context).size.width * 0.5 - 50,
                child: Image.asset(
                  'assets/images/soriic_logo.png', // Replace with your image asset path
                  width: 120,
                  height: 120,
                  color: Colors.deepPurple,
                ),
              ),

              // Center the form contents
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 250), // Increased space at the top for form
                    Text(
                      "Login to your account",
                      style: TextStyle(color: Colors.deepPurple),
                    ), // Added comma here
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        loginController.email.value = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Email',
                        labelStyle: TextStyle(
                          color: Colors.deepPurple, // Change this to any color you want
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        filled: true,
                        fillColor: Color(0xFFC5B4E3),
                        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        loginController.password.value = value;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: const TextStyle(
                          color: Colors.deepPurple, // Change this to any color you want
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFC5B4E3),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: loginController.forgotPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign in Button
                    ElevatedButton(
                      onPressed: loginController.login, // This will trigger the login method
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(horizontal: 70, vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text("Sign in", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),

                    const SizedBox(height: 20),

                    // Create account link at the bottom
                    Align( // Ensure alignment is correct
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>Signup(),
                            ),
                          );
                        },
                        child:  Text(
                          "Don't have an account? Create One ",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
