import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordController extends GetxController {
  var currentPassword = ''.obs;
  var newPassword = ''.obs;
  var confirmPassword = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Method to validate the fields
  bool validateFields() {
    if (currentPassword.value.isEmpty ||
        newPassword.value.isEmpty ||
        confirmPassword.value.isEmpty) {
      Get.snackbar('Error', 'All fields must be filled',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return false;
    }
    if (newPassword.value != confirmPassword.value) {
      Get.snackbar('Error', 'Passwords do not match',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return false;
    }
    if (newPassword.value.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return false;
    }
    return true;
  }

  // Function to handle the change password logic
  Future<void> changePassword() async {
    if (!validateFields()) return;

    User? user = _auth.currentUser;

    // Debugging the current user
    print("Logged in user: ${user?.email}");

    // Ensure the user is logged in
    if (user == null) {
      Get.snackbar('Error', 'User not logged in',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      return;
    }

    try {
      // Reauthenticate the user
      await reauthenticateUser(); // Reauthentication function is called here

      // Update the password in Firebase Auth
      await user.updatePassword(newPassword.value);

      // Optionally update the password in Firestore (staff collection)
      await firestore.collection('staff').doc(user.uid).update({
        'password': newPassword.value,
      });

      // Clear input fields on successful password change
      currentPassword.value = '';
      newPassword.value = '';
      confirmPassword.value = '';

      Get.snackbar('Success', 'Password changed successfully!',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green);

      // Navigate back to the previous screen
      Get.back();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        Get.snackbar('Error', 'Current password is incorrect',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      } else {
        Get.snackbar('Error', e.message ?? 'An error occurred',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to change password',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      print("Change password error: $e");
    }
  }

  // Function to reauthenticate the user
  Future<void> reauthenticateUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword.value,
        );

        await user.reauthenticateWithCredential(credential);
        print('Reauthentication successful');
      } on FirebaseAuthException catch (e) {
        Get.snackbar('Error', 'Reauthentication failed: ${e.message}',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red);
      }
    } else {
      print('User is null');
    }
  }
}
