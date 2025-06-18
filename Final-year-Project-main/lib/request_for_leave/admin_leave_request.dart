import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/screens/admin/task_assignment/AdminTaskSubmissionsScreen.dart';
import '../../announcments/create_announcemnt.dart';
import '../screens/admin/posting_announcement.dart';
import '../screens/admin/task_assignment/task_assignment.dart';

class AdminLeaveRequestsScreen extends StatefulWidget {
  @override
  _AdminLeaveRequestsScreenState createState() =>
      _AdminLeaveRequestsScreenState();
}

class _AdminLeaveRequestsScreenState extends State<AdminLeaveRequestsScreen> {
  int _currentIndex = 2; // Set default index to 2 (Leave Requests tab)

  // Navigation logic for BottomNavigationBar
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateAnnouncementPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminAssignTaskScreen()),
        );
        break;
      case 2:
      // Stay on this screen
        break;
         case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminTaskSubmissionsScreen()),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B2C83),
        iconTheme: const IconThemeData(color: Colors.white), // Back arrow color
        title: const Text(
          "Employee Leave Request",
          style: TextStyle(color: Colors.white), // Title text color
        ),
      ),
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('leaveRequests')
                .where('status', isEqualTo: 'Pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: const Text(
                    "Error loading data. Please try again later.",
                    style: TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text(
                    "No pending leave requests.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              final leaveRequests = snapshot.data!.docs;

              return ListView.builder(
                itemCount: leaveRequests.length,
                itemBuilder: (context, index) {
                  final request = leaveRequests[index];
                  final data = request.data() as Map<String, dynamic>;

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  "Employee ID: ${data['userId']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis, // Handle overflow
                                ),
                              ),
                              Chip(
                                label: Text(
                                  data['status'],
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: data['status'] == "Pending"
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Start Date: ${data['startDate'].toDate()}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          Text(
                            "End Date: ${data['endDate'].toDate()}",
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Reason:",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(
                            data['reason'],
                            style: TextStyle(color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis, // Handle overflow
                            maxLines: 3, // Limit to 3 lines
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _updateLeaveStatus(
                                    context, request.id, "Approved"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                icon: const Icon(Icons.check),
                                label: const Text("Approve"),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _updateLeaveStatus(
                                    context, request.id, "Rejected"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                icon: const Icon(Icons.close),
                                label: const Text("Reject"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    bottomNavigationBar: Padding(
  padding: const EdgeInsets.only(bottom: 12, left: 9, right: 9), // lifted from bottom
  child: Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24), // rounded all 4 sides
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 12,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF4B2C83),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        iconSize: 28,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            label: "Announcements",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Assign Task",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.beach_access_outlined),
            label: "Leave",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt_outlined),
            label: "Submitted",
          ),
        ],
      ),
    ),
  ),
),
    );
  }

  /// Update the status of a leave request in Firestore
  void _updateLeaveStatus(
      BuildContext context, String requestId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('leaveRequests')
          .doc(requestId)
          .update({'status': status});

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Leave request updated to $status."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating leave request: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
