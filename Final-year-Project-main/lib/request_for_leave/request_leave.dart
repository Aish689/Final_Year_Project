import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../attendence/attendence_page.dart';
import 'Leave_History_screen.dart';

class LeaveRequestScreen extends StatefulWidget {
  @override
  _LeaveRequestScreenState createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _startDate;
  DateTime? _endDate;
  String? _reason;
  bool _isSubmitting = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _listenForLeaveUpdates();
  }

  void _listenForLeaveUpdates() {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      FirebaseFirestore.instance
          .collection('leaveRequests')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['status'] == 'Approved' || data['status'] == 'Rejected') {
            _showLeaveStatusNotification(
              data['status'],
              data['reason'],
              data['startDate'].toDate(),
              data['endDate'].toDate(),
            );
          }
        }
      });
    }
  }

  void _showLeaveStatusNotification(
      String status, String reason, DateTime startDate, DateTime endDate) {
    final message = status == 'Approved'
        ? "Your leave from ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)} has been approved."
        : "Your leave request from ${DateFormat('yyyy-MM-dd').format(startDate)} to ${DateFormat('yyyy-MM-dd').format(endDate)} was rejected.";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Leave Request $status"),
          content: Text("$message\nReason: $reason"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitLeaveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select both start and end dates.")),
      );
      return;
    }

    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("End date must be after or same as start date.")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("User not authenticated.")),
        );
        return;
      }

      await FirebaseFirestore.instance.collection('leaveRequests').add({
        'userId': userId,
        'startDate': _startDate,
        'endDate': _endDate,
        'reason': _reason,
        'status': 'Pending',
        'timestamp': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Leave request submitted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting request: $e")),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _pickStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        _startDate = selectedDate;
      });
    }
  }

  void _pickEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (selectedDate != null) {
      setState(() {
        _endDate = selectedDate;
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DashboardAttendanceScreen()),
      );
    } else if (index == 1) {
      // Stay on current screen
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LeaveHistoryScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text("Leave Request", style: TextStyle(color: Colors.white)),
      ),
      body: _buildLeaveRequestForm(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 9, right: 9),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: Colors.white,
              selectedItemColor: Color(0xFF4B2C83),
              unselectedItemColor: Colors.grey,
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.request_page),
                  label: "Leave Request",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: "Leave History",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveRequestForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Apply for Leave",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4B2C83),
              ),
            ),
            SizedBox(height: 20),
            _buildDatePickerField("From", _startDate, _pickStartDate),
            SizedBox(height: 16),
            _buildDatePickerField("To", _endDate, _pickEndDate),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: "Reason",
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Reason is required.";
                }
                return null;
              },
              onChanged: (value) => _reason = value,
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitLeaveRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B2C83),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Submit Request", style: TextStyle(fontSize: 16,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          controller: TextEditingController(
            text: date != null ? DateFormat('yyyy-MM-dd').format(date) : '',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "$label date is required.";
            }
            return null;
          },
        ),
      ),
    );
  }
}
