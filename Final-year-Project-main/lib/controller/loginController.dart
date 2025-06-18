import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/implementation_AI/attendance_forecast.dart';
import 'package:soricc/location.dart';
import 'package:soricc/screens/admin/employee_list_screen.dart';
import 'package:soricc/screens/employee_final%20_decision.dart';
import 'package:soricc/screens/employee_performance.dart';
import 'package:soricc/screens/start.dart';
import '../Device_ID/device_id.dart'; // Add this import at the top


import '../screens/forgetPassword.dart';

class LoginController extends GetxController {
 // String user_id = FirebaseAuth.instance.currentUser!.uid;
  // Observable variables for email and password
  var email = ''.obs;
  var password = ''.obs;

  // Firebase Firestore and FirebaseAuth instances
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  // Method for login using Firebase Authentication
  Future<void> login() async {
  try {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar('Error', 'Please enter both email and password', colorText: Colors.red);
      return;
    }

    // Get current device ID
    String? currentDeviceId = await getDeviceId();
    if (currentDeviceId == null) {
      Get.snackbar('Error', 'Failed to retrieve device ID', colorText: Colors.red);
      return;
    }

    // Sign in with email and password
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email.value,
      password: password.value,
    );

    // User logged in
    if (userCredential.user != null) {
      String userId = userCredential.user!.uid;

      // Fetch user document from Firestore
      DocumentSnapshot userDoc = await firestore.collection('staff').doc(userId).get();

      if (userDoc.exists) {
        String registeredDeviceId = userDoc.get('device_id');

        if (registeredDeviceId == currentDeviceId) {
          Get.snackbar('Success', 'Login successful', colorText: Colors.green);
          Get.to(() => ClockingSuccessScreen());
        } else {
          // ❌ Device mismatch – block login
          Get.snackbar('Error', 'You can only log in on your registered device.', colorText: Colors.red);
          await auth.signOut(); // Optional: sign out to clean up session
        }
      } else {
        Get.snackbar('Error', 'User data not found in Firestore', colorText: Colors.red);
      }
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      Get.snackbar('Error', 'No user found with this email', colorText: Colors.red);
    } else if (e.code == 'wrong-password') {
      Get.snackbar('Error', 'Incorrect password', colorText: Colors.red);
    } else {
      Get.snackbar('Error', e.message ?? 'Login failed', colorText: Colors.red);
    }
  } catch (error) {
    Get.snackbar('Error', 'Failed to login', colorText: Colors.red);
    print("Login failed: $error");
  }
}


  // Method for forgot password
  void forgotPassword() {
    if (email.value.isEmpty) {
      Get.snackbar('Error', 'Please enter your email to reset password', colorText: Colors.red);
    } else {
      auth.sendPasswordResetEmail(email: email.value).then((_) {
        Get.snackbar('Success', 'Password reset email sent', colorText: Colors.green);

        // Navigate to ForgotPassword screen and pass email as argument
        Get.to(() => ForgotPassword(), arguments: email.value);
      }).catchError((error) {
        Get.snackbar('Error', 'Failed to send password reset email', colorText: Colors.red);
      });
    }
  }
}
