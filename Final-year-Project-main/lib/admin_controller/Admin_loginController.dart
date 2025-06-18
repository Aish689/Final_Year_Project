import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/screens/admin/admin_dashboard.dart';
import 'package:soricc/screens/admin/admin_profile.dart';
import 'package:soricc/screens/admin/check_employee_bonus.dart';
import 'package:soricc/screens/admin/employee_list_screen.dart';
import 'package:soricc/screens/admin/performance_analysis.dart';
import 'package:soricc/screens/admin/userListScrenn.dart';
import 'package:soricc/screens/admin/task_assignment/AdminTaskSubmissionsScreen.dart';
import 'package:soricc/screens/dashboard.dart';
import '../screens/admin/posting_announcement.dart';
import '../screens/forgetPassword.dart';
import '../screens/start.dart';

class AdminLogincontroller extends GetxController {
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

    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email.value,
      password: password.value,
    );

    if (userCredential.user != null) {
      DocumentSnapshot userDoc = await firestore.collection('admin').doc(userCredential.user!.uid).get();

      if (userDoc.exists) {
        Get.snackbar('Success', 'Login successful', colorText: Colors.green);
        Get.to(AdminDashboard ());
      } else {
        Get.snackbar('Error', 'Admin data not found in Firestore', colorText: Colors.red);
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
      // No need to go to custom reset screen — just prompt user to check email
    }).catchError((error) {
      Get.snackbar('Error', 'Failed to send password reset email', colorText: Colors.red);
    });
  }
}
}
