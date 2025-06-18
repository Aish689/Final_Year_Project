/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soricc/screens/admin/task_assignment/task_assignment.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createAnnouncement(
      String title, String content, String targetAudience, DateTime? expirationDate) async {
    try {
      await _db.collection('announcements').add({
        'title': title,
        'content': content,
        'targetAudience': targetAudience,
        'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating announcement: $e');
      throw Exception('Failed to create announcement');
    }
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height * 0.75);

    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height * 0.8);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6);
    var secondEndPoint = Offset(size.width, size.height * 0.75);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _targetAudience = 'all';
  DateTime? _expirationDate;
  bool _isLoading = false;
  final FirestoreService _db = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      body: Stack(
        children: [
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: 200,
              color: const Color(0xFFC5B4E3),
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 70,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home, color: Colors.black, size: 28),
                  SizedBox(width: 60),
                  Text(
                    "Announcement",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: EdgeInsets.only(top: 220),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.purple, width: 2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            buildTextField("Title", _titleController, "Enter title"),
                            SizedBox(height: 8),
                            buildTextField("Content", _contentController, "Enter content", maxLines: 3),
                            SizedBox(height: 8),
                            buildDropdown(),
                            SizedBox(height: 8),
                            buildDatePicker(),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                buildButton("Cancel", Colors.grey, () {
                                  _titleController.clear();
                                  _contentController.clear();
                                  setState(() => _expirationDate = null);
                                }),
                                buildButton(
                                  _isLoading ? "Saving..." : "Send",
                                  _isLoading ? Colors.grey : Colors.purple,
                                  _isLoading ? null : saveAnnouncement,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 Widget buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        SizedBox(height: 3),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          maxLines: maxLines,
          validator: (value) => value!.isEmpty ? "Please enter $label" : null,
        ),
      ],
    );
  }

  Widget buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Target Audience", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        SizedBox(height: 3),
        DropdownButtonFormField<String>(
          value: _targetAudience,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          items: [
            DropdownMenuItem(value: 'all', child: Text('All Employees')),
            DropdownMenuItem(value: 'department', child: Text('Specific Department')),
            DropdownMenuItem(value: 'managers', child: Text('Managers')),
          ],
          onChanged: (value) => setState(() => _targetAudience = value!),
        ),
      ],
    );
  }

  Widget buildDatePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Expiration Date", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        SizedBox(height: 3),
        TextFormField(
          readOnly: true,
          decoration: InputDecoration(
            hintText: "Select expiration date",
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) setState(() => _expirationDate = pickedDate);
          },
          controller: TextEditingController(
            text: _expirationDate == null ? '' : _expirationDate!.toLocal().toString().split(' ')[0],
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, Color color, VoidCallback? onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      ),
      child: Text(text, style: TextStyle(color: Colors.white)),
    );
  }

  Future<void> saveAnnouncement() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('announcements').add({
        'title': _titleController.text,
        'content': _contentController.text,
        'targetAudience': _targetAudience,
        'expirationDate': _expirationDate != null ? Timestamp.fromDate(_expirationDate!) : null,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Announcement saved successfully!')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminAssignTaskScreen()));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save announcement: $error')));
    }
    setState(() => _isLoading = false);
  }
} */
import 'package:flutter/material.dart';
import 'package:soricc/screens/admin/task_assignment/AdminTaskSubmissionsScreen.dart';
import 'package:soricc/screens/admin/task_assignment/task_assignment.dart';
import '../../announcments/create_announcemnt.dart';
import '../../request_for_leave/admin_leave_request.dart';

class CreateAnnouncementPage extends StatefulWidget {
  @override
  _CreateAnnouncementPageState createState() => _CreateAnnouncementPageState();
}

class _CreateAnnouncementPageState extends State<CreateAnnouncementPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _targetAudience = 'all';
  DateTime? _expirationDate;

  int _currentIndex = 0; // Track the selected tab

  final FirestoreService _firestoreService = FirestoreService();

  Future<void> _submitAnnouncement() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _firestoreService.createAnnouncement(
          _titleController.text,
          _contentController.text,
          _targetAudience,
          _expirationDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Announcement posted successfully!')),
        );
        _formKey.currentState!.reset();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to post announcement: $e')),
        );
      }
    }
  }

  // Navigation logic for tabs
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
      // Stay on Create Announcement
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminAssignTaskScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminLeaveRequestsScreen()),
        );
        break;
        case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdminTaskSubmissionsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white), // Back arrow color
        title: Text(
          "Create Announcement",
          style: TextStyle(color: Colors.white), // Title text color
        ),
      ),
      body: Container(
        color: Colors.deepPurple[50],
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Title',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Enter title',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Content',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  hintText: 'Enter content',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the content';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text(
                'Target Audience',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              DropdownButtonFormField<String>(
                value: _targetAudience,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'all', child: Text('All Employees')),
                  DropdownMenuItem(value: 'department', child: Text('Specific Department')),
                  DropdownMenuItem(value: 'managers', child: Text('Managers')),
                ],
                onChanged: (value) {
                  setState(() {
                    _targetAudience = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              Text(
                'Expiration Date',
                style: TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  hintText: 'Select expiration date',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _expirationDate = pickedDate;
                    });
                  }
                },
                controller: TextEditingController(
                  text: _expirationDate == null ? '' : _expirationDate!.toLocal().toString().split(' ')[0],
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitAnnouncement,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Post Announcement',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
} Path getClip(Size size) {
    var path = Path();
    // Start at the top left corner
    path.lineTo(0, size.height * 0.75); // Start from a lower point

    // First wave curve
    var firstControlPoint = Offset(size.width / 4, size.height); // Control point at bottom
    var firstEndPoint = Offset(size.width / 2, size.height * 0.8); // End point lower
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    // Second wave curve
    var secondControlPoint = Offset(size.width * 0.75, size.height * 0.6); // Control point at mid-height
    var secondEndPoint = Offset(size.width, size.height * 0.75); // End point at lower
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    // Complete the path
    path.lineTo(size.width, 0); // Close at the top
    path.close();
    return path;
  }

