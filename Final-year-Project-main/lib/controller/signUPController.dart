import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_storage/get_storage.dart';
import '../Device_ID/device_id.dart';
import '../screens/login.dart';
import '../screens/start.dart';

class SignUpController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  late CollectionReference userCollection;

  TextEditingController registerNameCtrl = TextEditingController();
  TextEditingController registerEmailCtrl = TextEditingController();
  TextEditingController registerPasswordCtrl = TextEditingController();
  TextEditingController registerRoleCtrl = TextEditingController();
  TextEditingController registerContactCtrl = TextEditingController(text: '+92'); // Default Pakistani code

  GetStorage box = GetStorage();

  @override
  void onInit() {
    userCollection = firestore.collection('staff');
    super.onInit();
  }

  Future<void> addUser() async {
    try {
      // Ensure all fields are filled
      if (registerNameCtrl.text.isEmpty ||
          registerEmailCtrl.text.isEmpty ||
          registerPasswordCtrl.text.isEmpty ||
          registerRoleCtrl.text.isEmpty ||
          registerContactCtrl.text.isEmpty) {
        Get.snackbar('Error', 'Please fill all the fields', colorText: Colors.red);
        return;
      }

      // Validate email, contact, and password formats
      if (!isValidEmail(registerEmailCtrl.text)) {
        Get.snackbar('Error', 'Please enter a valid Gmail address', colorText: Colors.red);
        return;
      }
      if (!isValidContact(registerContactCtrl.text)) {
        Get.snackbar('Error', 'Please enter a valid contact number', colorText: Colors.red);
        return;
      }
      if (!isStrongPassword(registerPasswordCtrl.text)) {
        Get.snackbar('Error', 'Password requirements not met', colorText: Colors.red);
        return;
      }

      // Retrieve device ID
      String? deviceId = await getDeviceId();
      if (deviceId == null) {
        Get.snackbar('Error', 'Failed to retrieve device ID', colorText: Colors.red);
        return;
      }

      print("Device ID: $deviceId"); // Debugging device ID

      // Check if the device ID already exists in the database
      QuerySnapshot deviceCheck = await userCollection.where('device_id', isEqualTo: deviceId).get();
      if (deviceCheck.docs.isNotEmpty) {
        Get.snackbar('Error', 'This device is already registered with another account', colorText: Colors.red);
        return;
      }

      // Create a new user with Firebase Auth
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: registerEmailCtrl.text,
        password: registerPasswordCtrl.text,
      );

      print("User created successfully: ${userCredential.user?.uid}"); // Debugging Firebase User

      // Prepare user data to store in Firestore
      Map<String, dynamic> userData = {
        'name': registerNameCtrl.text,
        'email': registerEmailCtrl.text,
        'password': registerPasswordCtrl.text,
        'roleInCompany': registerRoleCtrl.text,
        'contactNumber': registerContactCtrl.text,
        'device_id': deviceId, // Store the unique device ID
      };

      // Save the user data to Firestore
      await userCollection.doc(userCredential.user!.uid).set(userData);
      Get.snackbar('Success', 'User registered successfully', colorText: Colors.green);

      // Clear the input fields
      registerNameCtrl.clear();
      registerEmailCtrl.clear();
      registerPasswordCtrl.clear();
      registerRoleCtrl.clear();
      registerContactCtrl.clear();

      // Redirect to success or home screen
      Get.to(ClockingSuccessScreen());
    } on FirebaseAuthException catch (e) {
      print("Firebase Auth Error: ${e.toString()}"); // Debugging Firebase Auth Error

      if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'This email is already in use', colorText: Colors.red);
      } else if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak', colorText: Colors.red);
      } else {
        Get.snackbar('Error', e.message ?? 'Registration failed', colorText: Colors.red);
      }
    } catch (error) {
      print("General Error: ${error.toString()}"); // Debugging general errors
      Get.snackbar('Error', 'Registration failed', colorText: Colors.red);
    }
  }

  bool isValidEmail(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@gmail\.com$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(email);
  }

  bool isStrongPassword(String password) {
    String pattern =
        r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(password);
  }

  bool isValidContact(String contact) {
    String pattern = r'^\+92\d{10}$';
    RegExp regExp = RegExp(pattern);
    return regExp.hasMatch(contact);
  }

  void forgotPassword() {
    print("Forgot Password clicked");
  }

  void loginAccount() {
    Get.to(LoginPage());
  }
}
