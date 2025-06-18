import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AttendanceCheckInScreen extends StatefulWidget {
  @override
  _AttendanceCheckInScreenState createState() => _AttendanceCheckInScreenState();
}

class _AttendanceCheckInScreenState extends State<AttendanceCheckInScreen> {
  Position? _currentPosition;
  bool _isSubmitting = false;
  int totalDaysInMonth = DateTime.now().day;
  int daysPresent = 0; // This will update dynamically

  @override
  void initState() {
    super.initState();
    _getLocation();
    _fetchAttendanceData();
  }

  Future<void> _fetchAttendanceData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final attendanceRecords = FirebaseFirestore.instance
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .snapshots()
          .listen((snapshot) {
        setState(() {
          daysPresent = snapshot.docs.length;
        });
      });

    } catch (e) {
      _showSnackBar("Error fetching attendance data: $e");
    }
  }


  Future<void> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      await Geolocator.openLocationSettings();
      _showSnackBar("Please enable location services in settings.");
      return;
    }

    var permissionStatus = await Permission.location.status;
    if (permissionStatus.isDenied) {
      permissionStatus = await Permission.location.request();
      if (!permissionStatus.isGranted) {
        _showSnackBar("Location permission denied. Please enable it in settings.");
        return;
      }
    }

    if (permissionStatus.isPermanentlyDenied) {
      _showSnackBar("Location permission permanently denied. Enable it in app settings.");
      openAppSettings();
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      _showSnackBar("Error retrieving location: $e");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _markAttendance() async {
    if (_currentPosition == null) await _getLocation();
    if (_currentPosition == null) {
      _showSnackBar("Please enable location to mark attendance.");
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Check if attendance already marked for today
      final snapshot = await FirebaseFirestore.instance
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .get();

      if (snapshot.docs.isNotEmpty) {
        _showSnackBar("You have already marked attendance for today.");
        setState(() => _isSubmitting = false);
        return;
      }

      // Mark attendance
      await FirebaseFirestore.instance.collection('attendance').add({
        'userId': userId,
        'timestamp': Timestamp.now(),
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
      });

      _showSnackBar("Attendance marked successfully!");
      _fetchAttendanceData(); // Refresh attendance data after marking
    } catch (e) {
      _showSnackBar("Failed to mark attendance. Error: $e");
    } finally {
      setState(() => _isSubmitting = false);
    }
  }


  double get attendancePercentage => daysPresent / totalDaysInMonth;

  @override
  Widget build(BuildContext context) {
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white), // Back arrow color
        title: Text(
          "Check-In",
          style: TextStyle(color: Colors.white), // Title text color
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Mark Your Attendance",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Current Date: $currentDate",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.location_on, color: Colors.red),
                      Expanded(
                        child: Text(
                          _currentPosition != null
                              ? "Location: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}"
                              : "Fetching location...",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _markAttendance,
                    icon: Icon(Icons.check_circle, color: Colors.white),
                    label: Text(
                      _isSubmitting ? "Marking Attendance..." : "Mark Attendance",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  if (_isSubmitting)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Attendance Progress",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            color: Colors.blueAccent,
                            value: daysPresent.toDouble(),
                            title: '${(attendancePercentage * 100).toStringAsFixed(1)}%',
                            radius: 50,
                            titleStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            color: Colors.grey[300],
                            value: (totalDaysInMonth - daysPresent).toDouble(),
                            title: '',
                            radius: 50,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "$daysPresent of $totalDaysInMonth days attended",
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  Stream<QuerySnapshot>? _attendanceStream;
  DateTime _selectedMonth = DateTime.now();
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAttendanceStream();
  }

  void _initializeAttendanceStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      setState(() {
        _errorMessage = 'User not authenticated';
      });
      return;
    }

    final startOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endOfMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
      0,
    );

    setState(() {
      _errorMessage = null;  // Reset previous error message if any
    });

    // Initialize the real-time listener for attendance records
    _attendanceStream = FirebaseFirestore.instance
        .collection('attendance')
        .where('userId', isEqualTo: userId)
        .where('timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
        .orderBy('timestamp', descending: true)
        .snapshots();

    // Check if the query returns an error (for debugging purposes)
    _attendanceStream!.listen(
          (snapshot) {
        // Successful stream, no error
        setState(() {
          _errorMessage = null;
        });
      },
      onError: (error) {
        // Error while fetching data
        setState(() {
          _errorMessage = 'Error fetching data: ${error.toString()}';
        });
      },
    );
  }

  void _selectMonth(BuildContext context) async {
    final DateTime? picked = await showMonthPicker(
      context: context,
      initialDate: _selectedMonth,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _initializeAttendanceStream();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Attendance History",
          style: TextStyle(color: Colors.white),
        ),
         centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectMonth(context),
          ),
        ],
      ),
      body: _errorMessage != null
          ? Center(
        child: Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red),
        ),
      )
          : StreamBuilder<QuerySnapshot>(
        stream: _attendanceStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading attendance data: ${snapshot.error}",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Text(
                "No attendance records found for this month",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final record = docs[index];
              final timestamp = (record['timestamp'] as Timestamp).toDate();
              final formattedDate =
              DateFormat('yyyy-MM-dd – hh:mm a').format(timestamp);
              final location = record['location'] as GeoPoint;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text(formattedDate),
                  subtitle: Text(
                    "Location: ${location.latitude.toStringAsFixed(5)}, ${location.longitude.toStringAsFixed(5)}",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


class AttendanceSummaryScreen extends StatefulWidget {
  @override
  _AttendanceSummaryScreenState createState() => _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  int totalDaysInMonth = DateTime.now().day;
  int daysPresent = 0;
  double attendancePercentage = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceSummary();
  }

  Future<void> _fetchAttendanceSummary() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      final attendanceRecords = await FirebaseFirestore.instance
          .collection('attendance')
          .where('userId', isEqualTo: userId)
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get();

      setState(() {
        daysPresent = attendanceRecords.docs.length;
        totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
        attendancePercentage = (daysPresent / totalDaysInMonth) * 100;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching attendance summary: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          "Check-In",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
     
      body: Column(
        children: [
          // Top Image
         SizedBox(height: 20)
,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "Attendance Summary for ${DateFormat('MMMM yyyy').format(DateTime.now())}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4B2C83)),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    _buildSummaryRow("Total Days in Month:", totalDaysInMonth.toString()),
                    SizedBox(height: 10),
                    _buildSummaryRow("Days Present:", daysPresent.toString()),
                    SizedBox(height: 10),
                    _buildSummaryRow(
                      "Attendance Percentage:",
                      "${attendancePercentage.toStringAsFixed(1)}%",
                      valueColor: Colors.blueAccent,
                    ),
                    SizedBox(height: 30),
                    Center(
                      child: SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: attendancePercentage / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            attendancePercentage >= 75 ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    Text(
                      attendancePercentage >= 75
                          ? "Attendance is satisfactory"
                          : "Attendance is below the required percentage",
                      style: TextStyle(
                        fontSize: 16,
                        color: attendancePercentage >= 75 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Image
         
          //  padding: const EdgeInsets.only(bottom: 20.0),
             Image.asset(
              'assets/images/bottom.jpeg',
              height: 140,
              fit: BoxFit.contain,
            ),
          
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 16)),
        Text(value, style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black)),
      ],
    );
  }
}