import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:soricc/notification%20.dart';
import 'package:soricc/screens/admin/admin_profile.dart';
import 'package:soricc/screens/admin/check_emplyees.dart';
import 'package:soricc/screens/admin/check_hours.dart';
import 'package:soricc/screens/admin/performance_analysis.dart';
import 'package:soricc/screens/admin/posting_announcement.dart';
import 'package:soricc/screens/admin/task_assignment/task_assignment.dart';
import 'package:soricc/screens/daily_task.dart';
import 'package:soricc/screens/justifiyHours.dart';
import 'package:soricc/screens/profile_screen.dart';
 // NEW IMPORT

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                ClipPath(
                  clipper: ProfileClipper(),
                  child: Container(
                    height: screenHeight * 0.55,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6F47B4),
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.05,
                  left: screenWidth * 0.5 - 75,
                  child: const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.17,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileButton(context),
                      _buildDailyTasksButton(context),
                    ],
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.42,
                  left: screenWidth * 0.5 - 110,
                  child: _buildJustifyHoursCard(context),
                ),
              ],
            ),
            const SizedBox(height: 2),
            _buildCenteredButton(context, 'See Employees', Icons.people, Colors.blue, EmployeesScreen()),
            const SizedBox(height: 15),
            _buildCenteredButton(context, 'Make Announcement', Icons.campaign, Colors.red, CreateAnnouncementPage()),
            const SizedBox(height: 15),
            _buildCenteredButton(context, 'Performance Analysis', Icons.bar_chart, Colors.green, PerformanceAnalysis()), // NEW BUTTON
          ],
        ),
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('admin')
        .doc(currentUser?.uid)
        .get(),
    builder: (context, snapshot) {
      String name = 'Loading...';

      if (snapshot.hasData && snapshot.data!.exists) {
        final data = snapshot.data!.data() as Map<String, dynamic>;
        name = data['name'] ?? 'No Name';
      } else if (snapshot.hasError) {
        name = 'Error';
      }

      return Container(
        width: 160, // Optional: slightly more space
        height: 100, // Increased from 90 to 100 or more
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/profile_avater.png'),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                    child: const Text(
                      'See Profile',
                      style: TextStyle(
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}


  Widget _buildDailyTasksButton(BuildContext context) {
    return Expanded(
      child: Container(
        height: 90,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.task_alt, size: 30, color: Colors.purple),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdminAssignTaskScreen()));
              },
              child: const Text(
                'Daily Tasks',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJustifyHoursCard(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_filled, size: 30, color: Color(0xFF6F47B4)),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => CheckHoursScreen()));
            },
            child: const Text(
              'Check Hours',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredButton(BuildContext context, String text, IconData icon, Color color, Widget screen) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 120);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 120);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
