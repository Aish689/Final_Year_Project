import 'package:flutter/material.dart';
import 'History_summary_checkIn.dart';

class AttendanceHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Attendance",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Welcome to Attendance",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2C83),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "Choose an option below",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    _buildAttendanceOption(
                      context,
                      icon: Icons.login,
                      label: "Check-In",
                      description: "Mark your attendance.",
                      color: Colors.lightBlueAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttendanceCheckInScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    _buildAttendanceOption(
                      context,
                      icon: Icons.history,
                      label: "View History",
                      description: "View your previous attendance records.",
                      color: Colors.orangeAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttendanceHistoryScreen()),
                        );
                      },
                    ),
                    SizedBox(height: 20),
                    _buildAttendanceOption(
                      context,
                      icon: Icons.bar_chart,
                      label: "View Summary",
                      description: "See a summary of your attendance stats.",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => AttendanceSummaryScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
         
            //padding: const EdgeInsets.only(bottom: 16.0),
            Image.asset(
            'assets/images/bottom.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 140, // Optional: fixed height
          ),
          
        ],
      ),
    );
  }

  Widget _buildAttendanceOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String description,
    required Color color,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4B2C83),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Colors.grey[500]),
            ],
          ),
        ),
      ),
    );
  }
}
