import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminCheckHours extends StatefulWidget {
  final String employeeId;
  final String employeeName;
  final DateTime selectedDate;

  AdminCheckHours({
    required this.employeeId,
    required this.employeeName,
    required this.selectedDate,
  });

  @override
  State<AdminCheckHours> createState() => _AdminCheckHoursState();
}

class _AdminCheckHoursState extends State<AdminCheckHours> {
  late String selectedUserId;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedUserId = widget.employeeId;
    selectedDate = widget.selectedDate;
  }

  // ✅ Fetch work hours for selected date only
  Stream<QuerySnapshot> fetchWorkHours(String userId, DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    return FirebaseFirestore.instance
        .collection('work_hours')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date') // Optional: Sort within the day
        .snapshots();
  }

  // ✅ Nice looking card
  Widget _buildCheckHourCard(String hours, String type, String brief, DateTime date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hours: $hours", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Type: $type", style: TextStyle(color: Colors.white, fontSize: 14)),
            SizedBox(height: 5),
            Text("Brief: $brief", style: TextStyle(color: Colors.white, fontSize: 14)),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                "${date.day}/${date.month}/${date.year}",
                style: TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Date Picker


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Check Work Hours")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Employee: ${widget.employeeName}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
           
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: fetchWorkHours(selectedUserId, selectedDate),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    return Center(child: Text("No work hours found"));

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final data = doc.data() as Map<String, dynamic>;
                      final timestamp = data['date'] as Timestamp;
                      final date = timestamp.toDate();

                      return _buildCheckHourCard(
                        data['hours'].toString(),
                        data['type'] ?? '',
                        data['brief'] ?? '',
                        date,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
