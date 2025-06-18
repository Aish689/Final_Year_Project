/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeFinalDecisionScreen extends StatelessWidget {
  const EmployeeFinalDecisionScreen({super.key, required String userId});
  
  get userId => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Image.asset(
                'assets/images/top.jpeg',
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Positioned(
                left: 55,
                top: 70,
                child: Text(
                  'Employees Final Decision',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getLatestDecisionStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  // Show under review message if no data
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.analytics,
                            size: 100,
                            color: Colors.blue,
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Employee evaluations for this month are under review.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please check back later to see the final decisions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final userId = data['userId'] ?? 'Unknown';
                    final decision = data['decision'] ?? 'No decision';
                    final avgAttendance = (data['average_attendance'] ?? 0).toDouble();
                    final avgPerformance = (data['average_performance'] ?? 0).toDouble();

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  decision.contains('Reward')
                                      ? Icons.thumb_up
                                      : decision.contains('Warning')
                                          ? Icons.warning
                                          : Icons.info,
                                  color: decision.contains('Reward')
                                      ? Colors.green
                                      : decision.contains('Warning')
                                          ? Colors.red
                                          : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'User ID: $userId',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Attendance: ${avgAttendance.toStringAsFixed(1)}%'),
                            Text('Performance: ${avgPerformance.toStringAsFixed(1)}%'),
                            const SizedBox(height: 4),
                            Text(
                              'Decision: $decision',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: decision.contains('Reward')
                                    ? Colors.green
                                    : decision.contains('Warning')
                                        ? Colors.red
                                        : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Image.asset(
            'assets/images/bottom.jpeg',
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }

  /// Returns a stream that listens to employee_decisions documents from current or previous month
 Stream<QuerySnapshot> _getLatestDecisionStream() {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();

  DateTime startCurrentMonth = DateTime(now.year, now.month, 1);
  DateTime startNextMonth =
      (now.month == 12) ? DateTime(now.year + 1, 1, 1) : DateTime(now.year, now.month + 1, 1);

  return firestore
      .collection('employee_decisions')
      .where('userId', isEqualTo: userId)
      .where('evaluated_at', isGreaterThanOrEqualTo: Timestamp.fromDate(startCurrentMonth))
      .where('evaluated_at', isLessThan: Timestamp.fromDate(startNextMonth))
      .snapshots();
}

}*/
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeFinalDecisionScreen extends StatelessWidget {
  final String userId;
  const EmployeeFinalDecisionScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
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
                    'Employee Final Decision',
                    style: TextStyle(
                      fontSize: 25,
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
                      return _buildNoDataMessage(
                        'There is no decision available at the moment.\nThe evaluation process is ongoing.',
                      );
                    }

                    final data = snapshot.data!.data() as Map<String, dynamic>?;
                    if (data == null || !data.containsKey('decision')) {
                      return _buildNoDataMessage(
                        'There is no decision available at the moment.\nThe evaluation process is ongoing.',
                      );
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
                                  'Performance Summary',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.deepPurple[800],
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

  Widget buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 18)),
      ],
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
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
