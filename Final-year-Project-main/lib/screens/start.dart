import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/screens/user_profile.dart';
import '../attendence/attendence_page.dart';
import 'dashboard.dart';

class ClockingSuccessScreen extends StatelessWidget {
  Future<bool> checkProfileCompletion(String userId) async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('staff').doc(userId).get();

    if (userDoc.exists) {
      Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
      if (data != null &&
          data.containsKey('expertise') &&
          data.containsKey('experience') &&
          data.containsKey('workingHours') &&
          data['expertise'].toString().isNotEmpty &&
          data['experience'].toString().isNotEmpty &&
          data['workingHours'].toString().isNotEmpty) {
        return true; // Profile is complete
      }
    }
    return false; // Profile is incomplete
  } catch (e) {
    debugPrint("Error checking profile completion: $e");
    return false; // Assume incomplete if an error occurs
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipPath(
              clipper: BannerClipper(),
              child: Container(
                width: double.infinity,
                height: 420,
                margin: const EdgeInsets.only(left: 20, right: 20, top: 40),
                color: const Color(0xFF4B2C83),
                padding: const EdgeInsets.all(20),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Clocking Success\nWith Sorric',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 35,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    ),
                    Icon(
                      Icons.checklist_rounded,
                      size: 100,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 30.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Master Your\nWork Hours with\nSorric',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontSize: 30.0,
                    color: Color(0xFF4B2C83),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Elevate Your Work Hours with Confidence',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.grey,
              ),
            ),
            Spacer(),
            // Row for Start and Attendance buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Button
                ElevatedButton(
  onPressed: () async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      bool isProfileComplete = await checkProfileCompletion(currentUser.uid);

      if (isProfileComplete) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DashboardPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage(user: currentUser)),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently signed in!')),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF4B2C83),
    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  child: const Text(
    'Start',
    style: TextStyle(
      fontSize: 18.0,
      color: Colors.white,
    ),
  ),
),

                const SizedBox(width: 20), // Space between the buttons
                // Attendance Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardAttendanceScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4B2C83),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Attendance',
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30), // Space at the bottom
          ],
        ),
        
      ),
    );
  }
}

class BannerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, 40);
    path.quadraticBezierTo(0, 0, 40, 0);
    path.lineTo(size.width - 40, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 40);
    path.lineTo(size.width, size.height - 100);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height - 100);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
