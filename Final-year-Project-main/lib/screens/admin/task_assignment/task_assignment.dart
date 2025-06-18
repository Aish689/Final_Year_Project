import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soricc/screens/admin/admin_dashboard.dart';
import 'package:soricc/screens/admin/task_assignment/AdminTaskSubmissionsScreen.dart';

import '../../../request_for_leave/admin_leave_request.dart';
import '../posting_announcement.dart';

class AdminAssignTaskScreen extends StatefulWidget {
  @override
  _AdminAssignTaskScreenState createState() => _AdminAssignTaskScreenState();
}

class _AdminAssignTaskScreenState extends State<AdminAssignTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _employeeId;
  String _taskTitle = '';
  String _taskDescription = '';
  DateTime? _dueDate;
  final TextEditingController _dateController = TextEditingController();

  int _currentIndex = 1;

  Future<void> _submitTask() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        if (_employeeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Please select an employee')),
          );
          return;
        }

        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: User not authenticated')),
          );
          return;
        }

        await FirebaseFirestore.instance.collection('tasks').add({
          'employeeId': _employeeId,
          'taskTitle': _taskTitle,
          'taskDescription': _taskDescription,
          'dueDate': _dueDate != null ? Timestamp.fromDate(_dueDate!) : null,
          'createdAt': Timestamp.now(),
          'assignedBy': user.uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task assigned successfully')),
        );

        setState(() {
          _employeeId = null;
          _taskTitle = '';
          _taskDescription = '';
          _dueDate = null;
          _dateController.clear();
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminDashboard()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to assign task: $e')),
        );
      }
    }
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

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
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminLeaveRequestsScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminTaskSubmissionsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade400),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Assign Task to Employee",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('staff').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Center(child: CircularProgressIndicator());

                  List<DropdownMenuItem<String>> employeeItems = snapshot.data!.docs.map((doc) {
                    String employeeId = doc.id;
                    String employeeName = doc['name'] ?? 'Unknown';
                    return DropdownMenuItem(
                      value: employeeId,
                      child: Text('$employeeName ($employeeId)'),
                    );
                  }).toList();

                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Select Employee',
                      border: border,
                      focusedBorder: border.copyWith(
                        borderSide: BorderSide(color: Color(0xFF4B2C83)),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    value: _employeeId,
                    items: employeeItems,
                    onChanged: (value) => setState(() => _employeeId = value),
                    validator: (value) =>
                        value == null ? 'Please select an employee' : null,
                  );
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  hintText: 'Enter task title',
                  border: border,
                  focusedBorder: border.copyWith(
                    borderSide: BorderSide(color: Color(0xFF4B2C83)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Task Title' : null,
                onSaved: (value) => _taskTitle = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Task Description',
                  hintText: 'Enter detailed task description',
                  border: border,
                  focusedBorder: border.copyWith(
                    borderSide: BorderSide(color: Color(0xFF4B2C83)),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                maxLines: 3,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter Task Description' : null,
                onSaved: (value) => _taskDescription = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDueDate(context),
                decoration: InputDecoration(
                  labelText: 'Due Date',
                  hintText: 'Select due date',
                  border: border,
                  focusedBorder: border.copyWith(
                    borderSide: BorderSide(color: Color(0xFF4B2C83)),
                  ),
                  suffixIcon: Icon(Icons.calendar_today, color: Colors.grey),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitTask,
                child: Text('Assign Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B2C83),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
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
}
