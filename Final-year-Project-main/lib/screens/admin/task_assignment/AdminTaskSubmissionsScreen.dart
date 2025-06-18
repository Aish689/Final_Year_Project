import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminTaskSubmissionsScreen extends StatefulWidget {
  @override
  _AdminTaskSubmissionsScreenState createState() => _AdminTaskSubmissionsScreenState();
}

class _AdminTaskSubmissionsScreenState extends State<AdminTaskSubmissionsScreen> {
  Future<List<Map<String, dynamic>>> fetchSubmittedTasks() async {
    QuerySnapshot taskSnapshot = await FirebaseFirestore.instance.collection('tasks').get();
    List<Map<String, dynamic>> submissions = [];

    for (var doc in taskSnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('submittedBy')) {
        String employeeId = data['submittedBy'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('staff').doc(employeeId).get();
        var userData = userDoc.data() as Map<String, dynamic>?;

        submissions.add({
          'taskTitle': data['taskTitle'],
          'employeeId': employeeId,
          'employeeName': userData?['name'] ?? 'Unknown',
          'dueDate': (data['dueDate'] as Timestamp?)?.toDate(),
          'submissionDate': (data['submissionDate'] as Timestamp?)?.toDate(),
          'screenshotBase64': data['submissionImageBase64'],
        });
      }
    }

    return submissions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Submissions' ,
        style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4B2C83),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchSubmittedTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No task submissions found."));
          }

          var submissions = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              var task = submissions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task['taskTitle'] ?? "Untitled Task",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2C83),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.grey, size: 18),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              task['employeeName'],
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.badge, color: Colors.grey, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            "ID: ${task['employeeId']}",
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (task['submissionDate'] != null)
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Submitted: ${DateFormat('yyyy-MM-dd').format(task['submissionDate'])}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      if (task['dueDate'] != null)
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              "Due: ${DateFormat('yyyy-MM-dd').format(task['dueDate'])}",
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      const SizedBox(height: 12),
                      const Text(
                        "Screenshot of work:",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (task['screenshotBase64'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(task['screenshotBase64']),
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Text("No screenshot uploaded", style: TextStyle(color: Colors.red)),
                    ],
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
