import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/signUPController.dart';
import 'login.dart';

class Signup extends StatelessWidget {
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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

            // Logo on the wave
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
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 220),
                    _buildTextField('Enter Name', signUpController.registerNameCtrl),
                    const SizedBox(height: 20),
                    _buildTextField('Enter Email', signUpController.registerEmailCtrl),
                    const SizedBox(height: 20),
                    _buildTextField('Password', signUpController.registerPasswordCtrl, obscureText: true),
                    const SizedBox(height: 20),
                    _buildTextField('Role in Company', signUpController.registerRoleCtrl),
                    const SizedBox(height: 20),
                    _buildTextField('Contact Number', signUpController.registerContactCtrl),
                    const SizedBox(height: 20),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: signUpController.forgotPassword,
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Button
                    ElevatedButton(
                      onPressed: signUpController.addUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 17),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(17),
                        ),
                      ),
                      child: const Text("Sign Up", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),

                    const SizedBox(height: 20),

                    // Login link
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: signUpController.loginAccount,
                        child: const Text(
                          "Do you already have an account? Login",
                          style: TextStyle(color: Colors.deepPurple),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for building TextFields
  Widget _buildTextField(String label, TextEditingController controller, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.deepPurple,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
        ),
        filled: true,
        fillColor: const Color(0xFFC5B4E3),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      ),
    );
  }
}
