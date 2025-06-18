import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';  // Import local_auth package
import 'package:soricc/screens/admin/task_assignment/task_assignment.dart';
import 'package:soricc/screens/daily_task.dart';
import 'package:soricc/screens/signUp.dart';
import 'attendence/History_summary_checkIn.dart';
import 'controller/signUPController.dart';
import 'firebase_options.dart';
import 'package:soricc/screens/startPage/startPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);  // Initialize Firebase

  Get.put(SignUpController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:const Authenticator(),
    );
  }
}

class Authenticator extends StatefulWidget {
  const Authenticator({Key? key}) : super(key: key);

  @override
  _AuthenticatorState createState() => _AuthenticatorState();
}

class _AuthenticatorState extends State<Authenticator> {
  final LocalAuthentication auth = LocalAuthentication();
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticateUser();
  }

  Future<void> _authenticateUser() async {
    while (!isAuthenticated) {
      isAuthenticated = await _performBiometricAuth();
      if (!isAuthenticated) {
        // Optionally show a message or exit the app
        await _showUnauthorizedMessage();
      }
    }
    // Navigate to the main app after successful authentication
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  CreateAccountPage()),
    );
  }

  Future<bool> _performBiometricAuth() async {
    bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (canAuthenticateWithBiometrics && isDeviceSupported) {
      try {
        return await auth.authenticate(
          localizedReason: 'Please authenticate to access the app',
          options: const AuthenticationOptions(biometricOnly: true),
        );
      } catch (e) {
        print("Error during authentication: $e");
      }
    }
    return false;
  }

  Future<void> _showUnauthorizedMessage() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Authentication Failed'),
          content: const Text('Please authenticate using your fingerprint.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isAuthenticated
            ? CircularProgressIndicator() // Show a loading indicator while authenticating
            : Text('Waiting for authentication...'), // Show message until authenticated
      ),
    );
  }
}



