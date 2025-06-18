import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/screens/admin/see_employee_profile.dart';
import 'package:soricc/screens/chatScreenUser.dart';
import 'package:soricc/screens/employee_final%20_decision.dart';
import '../request_for_leave/request_leave.dart';
import 'attendenceHomeScreen.dart';

class DashboardAttendanceScreen extends StatefulWidget {
  @override
  _DashboardAttendanceScreenState createState() =>
      _DashboardAttendanceScreenState();
}

class _DashboardAttendanceScreenState extends State<DashboardAttendanceScreen> {
  String? userName;
  String? userPassword;
  String? userEmail;
  String? userRoleInCompany;
  String? userProfileImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('staff')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'];
          userPassword = userDoc['password'];
          userEmail = userDoc['email'];
          userRoleInCompany = userDoc['roleInCompany'];
          userProfileImage = userDoc['profileImage'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User data not found.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = Color(0xFF4B2C83);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: themeColor,
        elevation: 4,
        title: const Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.message_outlined),
            onPressed: () {
              if (userName == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("User data is still loading.")),
                );
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserChatScreen(
                    chatRoomId:
                        FirebaseAuth.instance.currentUser?.uid ?? 'chatRoom',
                    userName: userName!,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileCard(themeColor),
            const SizedBox(height: 20),
            _buildDashboardGrid(themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(Color themeColor) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      color: Color(0xFFEDE7F6),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: userProfileImage != null
                      ? NetworkImage(userProfileImage!)
                      : AssetImage('assets/default_avatar.png')
                          as ImageProvider,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    userName ?? 'Loading...',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildInfoRow("Email", userEmail),
            _buildInfoRow("Password", userPassword),
            _buildInfoRow("Role", userRoleInCompany),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Loading...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
Widget _buildDashboardGrid(Color themeColor) {
  return Column(
    children: [
      // First row with two tiles
      Row(
        children: [
          Expanded(
            child: _buildDashboardTile(
              icon: Icons.access_time,
              label: "Attendance",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AttendanceHomeScreen()),
              ),
              themeColor: themeColor,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: _buildDashboardTile(
              icon: Icons.event_available,
              label: "Leave Request",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaveRequestScreen()),
              ),
              themeColor: themeColor,
            ),
          ),
        ],
      ),
      SizedBox(height: 16),
      // Second row with one centered tile
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2 - 8,
            child: _buildDashboardTile(
              icon: Icons.analytics_outlined,
              label: "Performance",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>EmployeeDecisionScreen()),
              ),
              themeColor: themeColor,
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildDashboardTile({
  required IconData icon,
  required String label,
  required Function() onTap,
  required Color themeColor,
}) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      height: 180,
      child: Container(
        decoration: BoxDecoration(
          color: themeColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.3),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
             ),
            )
          ],
        ),
      ),
    ),
  );
}
}
   