import 'package:flutter/material.dart';
import 'package:soricc/screens/admin/check_employee_bonus.dart';
import 'package:soricc/screens/admin/check_emplyees.dart';
import 'package:soricc/screens/admin/check_hours.dart';
import 'package:soricc/screens/admin/employee_list_screen.dart';
import 'package:soricc/screens/admin/employee_reward.dart';
import 'package:soricc/screens/admin/posting_announcement.dart';
import 'package:soricc/screens/admin/userListScrenn.dart';

class PerformanceAnalysis extends StatelessWidget {
  const PerformanceAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
  body: SingleChildScrollView(
    child: Column(
      children: [
        Stack(
          children: [
            ClipPath(
              clipper: ProfileClipper(),
              child: Container(
                height: screenHeight * 0.42,
                decoration: const BoxDecoration(
                  color: Color(0xFF6F47B4),
                ),
              ),
            ),
            Positioned(
              top: screenHeight * 0.05,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width:50),
                  const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: screenHeight * 0.30,
              left: screenWidth * 0.5 - 140,
              child: _buildAttendancePredictionCard(context),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildCenteredButton(
          context,
          'Performance Prediction',
          Icons.trending_up,
          Colors.blue,
          UserListScreen(),
        ),
        const SizedBox(height: 15),
        _buildCenteredButton(
          context,
          'Check Employee Reward',
          Icons.emoji_events,
          Colors.green,
          CheckEmployeeBonus(),
        ),
        const SizedBox(height: 20),
      ],
    ),
  ),
  bottomNavigationBar: SizedBox(
    height: 145,
    child: Image.asset(
      'assets/images/bottom.jpeg',
      fit: BoxFit.cover,
    ),
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

  Widget _buildAttendancePredictionCard(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeListScreen()));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.access_time_filled, size: 30, color: Color(0xFF6F47B4)),
          SizedBox(width: 10),
          Text(
            'Attendance Prediction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
