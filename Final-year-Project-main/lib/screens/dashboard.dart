import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soricc/screens/profile_screen.dart';
import '../announcments/fetch_announcemnt.dart';
import 'daily_task.dart';
import 'justifiyHours.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              ClipPath(
                clipper: ProfileClipper(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6F47B4),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.05,
                left: MediaQuery.of(context).size.width * 0.5 - 75,
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
                top: MediaQuery.of(context).size.height * 0.17,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildProfileButton(context),
                    _buildDailyTasksButton(context),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.4,
                left: 6,
                right: 6,
                child: _buildJustifyHoursCard(context),
              ),
            ],
          ),
          const SizedBox(height: 87),
          Expanded(
            child: SingleChildScrollView(
              child: _buildAnnouncementSection(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileButton(BuildContext context) {
  final currentUser = FirebaseAuth.instance.currentUser;

  return FutureBuilder<DocumentSnapshot>(
    future: FirebaseFirestore.instance
        .collection('staff')
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
        width: 140,
        height: 90,
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage('assets/images/profile_avater.png'),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProfileScreen()),
                    );
                  },
                  child: const Text(
                    'See Profile',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}

  Widget _buildDailyTasksButton(BuildContext context) {
    return Container(
      width: 133,
      height: 90,
      decoration: BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 30,
            color: Colors.purple,
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskScreen()),
              );
            },
            child: const Text(
              'Daily Tasks',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJustifyHoursCard(BuildContext context) {
    return Container(
      width: 180,
      child: Center(
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(width: 2, color: Colors.white),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_filled,
                size: 30,
                color: Color(0xFF6F47B4),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => WorkHoursScreen()),
                  );
                },
                child: const Text(
                  'Justify Hours',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementSection() {
    final FirestoreService _firestoreService = FirestoreService();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF5B3A9A),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Announcements',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _firestoreService.fetchAnnouncements(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: TextStyle(color: Colors.white)),
                    );
                  }
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final announcements = snapshot.data!;
                  return Column(
                    children: announcements.map((announcement) {
                      return _buildAnnouncementCard(
                        title: announcement['title'],
                        content: announcement['content'],
                        time: announcement['time'] ?? 'N/A',
                        date: announcement['date'] ?? 'N/A',
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.bottomRight,
            child: Text(
              'See more',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard({
    required String title,
    required String content,
    required dynamic time,
    required dynamic date,
  }) {
    String formattedTime = 'N/A';
    String formattedDate = 'N/A';

    try {
      if (time is Timestamp) {
        formattedTime = DateFormat('HH:mm').format(time.toDate());
      } else if (time is String && time.isNotEmpty) {
        formattedTime = time;
      }
    } catch (e) {
      print('Error formatting time: $e');
    }

    try {
      if (date is Timestamp) {
        formattedDate = DateFormat('dd/MM/yyyy').format(date.toDate());
      } else if (date is String && date.isNotEmpty) {
        formattedDate = date;
      }
    } catch (e) {
      print('Error formatting date: $e');
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFF7B58C1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.campaign_outlined, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Text(
            content,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Clipper Class
class ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
