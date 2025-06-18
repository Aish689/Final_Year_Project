import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmployeeDecisionScreen extends StatelessWidget {
  const EmployeeDecisionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'User not logged in',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(
              'assets/images/bottom.jpeg',
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
            ),
          ),
          Column(
            children: [
              ClipPath(
                clipper: ProfileClipper(),
                child: Container(
                  height: 230,
                  width: double.infinity,
                  color: Colors.deepPurple,
                  alignment: Alignment.center,
                  child: const Text(
                    'Your Final Decision',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black38,
                          offset: Offset(0, 3),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('employee_decisions')
                      .doc(userId)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.deepPurple),
                      );
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      final now = DateTime.now();
                      if (now.day <= 7) {
                        return _buildNoDataMessage(
                          "It's early in the month.\nBonus and reward decisions will be updated soon.",
                        );
                      } else {
                        return _buildNoDataMessage(
                          'There is no decision available at the moment.\nThe evaluation process is ongoing.',
                        );
                      }
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;

                    if (data == null || !data.containsKey('decision')) {
                      final now = DateTime.now();
                      if (now.day <= 7) {
                        return _buildNoDataMessage(
                          "It's early in the month.\nBonus and reward decisions will be updated soon.",
                        );
                      } else {
                        return _buildNoDataMessage(
                          'There is no decision available at the moment.\nThe evaluation process is ongoing.',
                        );
                      }
                    }

                                final decision = data['decision'] ?? 'No decision';
final avgAttendance = (data['average_attendance_pct'] ?? 0).toDouble();
final avgPerformance = (data['average_performance_pct'] ?? 0).toDouble();

                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 110),
                      child: Center(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor: Colors.deepPurple.withOpacity(0.4),
                          child: Padding(
                            padding: const EdgeInsets.all(28.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(
                                  decision.contains('Reward')
                                      ? Icons.emoji_events
                                      : decision.contains('Warning')
                                          ? Icons.warning_amber_rounded
                                          : Icons.info_outline,
                                  size: 72,
                                  color: decision.contains('Reward')
                                      ? Colors.green
                                      : decision.contains('Warning')
                                          ? Colors.red
                                          : Colors.deepPurple,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Your Performance Summary',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.deepPurple[800],
                                    letterSpacing: 0.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 22),
                                buildInfoRow('Average Attendance', '${avgAttendance.toStringAsFixed(1)}%'),
                                const SizedBox(height: 12),
                                buildInfoRow('Average Performance', '${avgPerformance.toStringAsFixed(1)}%'),
                                const Divider(height: 40, thickness: 1.5),
                                Text(
                                  decision,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    color: decision.contains('Reward')
                                        ? Colors.green
                                        : decision.contains('Warning')
                                            ? Colors.red
                                            : Colors.deepPurple,
                                    letterSpacing: 0.7,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
Widget _buildNoDataMessage(String message) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.only(bottom: 150, left: 32.0, right: 32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 64,
              color: Colors.deepPurple.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Heads up!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}


  Widget buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            )),
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            )),
      ],
    );
  }
}

class ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 80);
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 80);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
