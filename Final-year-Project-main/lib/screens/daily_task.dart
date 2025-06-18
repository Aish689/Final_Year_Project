import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soricc/screens/employee_performance.dart';

import 'dashboard.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Get the logged-in user's UID (employeeId)
    String? employeeId = FirebaseAuth.instance.currentUser?.uid;

    // If the user is not logged in, show a message
    if (employeeId == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'User is not logged in.',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Daily Task", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
       // leading: const Icon(Icons.home, color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            ClipPath(
              clipper: ProfileClipper(),
              child: Container(
                color: Colors.deepPurple,
                height: 300,
                width: double.infinity,
                child: Center(
                  child: Icon(Icons.horizontal_rule_rounded, color: Colors.white, size: 50),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 110),
              child: _buildTaskSection(context, employeeId),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskSection(BuildContext context, String employeeId) {
  return Container(
    padding: const EdgeInsets.all(16),
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: const BoxDecoration(
      color: Color(0xFF5B3A9A),
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Your Tasks',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(height: 20),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('tasks')
              .where('employeeId', isEqualTo: employeeId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No tasks assigned',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Column(
              children: snapshot.data!.docs.map((doc) {
                var task = doc.data() as Map<String, dynamic>;
                String title = task['taskTitle'] ?? 'No Title';
                String date = _formatTimestamp(task['createdAt']);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailScreen(taskId: doc.id),
                      ),
                    );
                  },
                  child: _buildTaskCard(
                    title: title,
                    time: 'Posted on $date',
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    ),
  );
}


  Widget _buildTaskCard({required String title, required String time}) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xFF7B58C1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assignment, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 10),
                Text(time, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper function to format Firestore Timestamp
  String _formatTimestamp(dynamic timestamp) {
    try {
      if (timestamp is Timestamp) {
        return DateFormat('yyyy-MM-dd').format(timestamp.toDate());
      }
    } catch (e) {
      print("Error formatting timestamp: $e");
    }
    return 'Unknown Date';
  }
}

// ProfileClipper implementation for visual styling
class ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);
    path.quadraticBezierTo(size.width / 2, size.height - 100, size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
