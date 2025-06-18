import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get_storage/get_storage.dart';

import '../screens/admin/Admin_login.dart';
import '../screens/admin/posting_announcement.dart';
import '../screens/start.dart';

class AdminSignupcontroller extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController registerNameCtrl = TextEditingController();
  TextEditingController registerEmailCtrl = TextEditingController();
  TextEditingController registerPasswordCtrl = TextEditingController();
  TextEditingController registerRoleCtrl = TextEditingController();
  TextEditingController registerContactCtrl = TextEditingController(text: '+92');

  GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
  }

  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    String pattern = r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  bool isValidContact(String contact) {
    String pattern = r'^\+92\d{10}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(contact);
  }

  Future<void> addUser() async {
    try {
      if (registerNameCtrl.text.isEmpty ||
          registerEmailCtrl.text.isEmpty ||
          registerPasswordCtrl.text.isEmpty ||
          registerRoleCtrl.text.isEmpty ||
          registerContactCtrl.text.isEmpty) {
        Get.snackbar('Error', 'Please fill all the fields', colorText: Colors.red);
        return;
      }

      if (!isValidEmail(registerEmailCtrl.text)) {
        Get.snackbar('Error', 'Please enter a valid Gmail address', colorText: Colors.red);
        return;
      }

      if (!isValidContact(registerContactCtrl.text)) {
        Get.snackbar('Error', 'Please enter a valid contact number starting with +92 followed by 10 digits', colorText: Colors.red);
        return;
      }

      if (!isStrongPassword(registerPasswordCtrl.text)) {
        Get.snackbar(
          'Error',
          'Password must be at least 8 characters, include uppercase, lowercase, number, and special character',
          colorText: Colors.red,
        );
        return;
      }

      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: registerEmailCtrl.text,
        password: registerPasswordCtrl.text,
      );

      Map<String, dynamic> userData = {
        'name': registerNameCtrl.text,
        'email': registerEmailCtrl.text,
        'roleInCompany': registerRoleCtrl.text,
        'contactNumber': registerContactCtrl.text,
        'password': registerPasswordCtrl.text,
      };

      await firestore.collection('admin').doc(userCredential.user!.uid).set(userData);

      Get.snackbar('Success', 'User registered successfully', colorText: Colors.green);

      registerNameCtrl.clear();
      registerEmailCtrl.clear();
      registerPasswordCtrl.clear();
      registerRoleCtrl.clear();
      registerContactCtrl.clear();

      Get.to(CreateAnnouncementPage());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'This email is already in use', colorText: Colors.red);
      } else if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak', colorText: Colors.red);
      } else {
        Get.snackbar('Error', e.message ?? 'Registration failed', colorText: Colors.red);
      }
    } catch (error) {
      Get.snackbar('Error', 'Registration failed', colorText: Colors.red);
      print("Firestore Error: $error");
    }
  }

  void forgotPassword() {
    print("Forgot Password clicked");
  }

  void loginAccount() {
    Get.to(AdminLoginPage());
  }
}
