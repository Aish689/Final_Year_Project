import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Map<String, dynamic>? taskData;
  File? selectedFile;
  bool isSubmitting = false;
  String? uploadedFileBase64;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    fetchTaskDetails();
  }

  Future<void> fetchTaskDetails() async {
    var doc = await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).get();
    if (doc.exists) {
      setState(() {
        taskData = doc.data();
      });
    }
  }

  Future<void> pickFile() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<String> encodeImageToBase64(File imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    return base64Encode(imageBytes);
  }

  Future<void> submitTask() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please choose a screenshot")));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      String employeeId = FirebaseAuth.instance.currentUser!.uid;
      String base64Image = await encodeImageToBase64(selectedFile!);

      await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update({
        'submittedBy': employeeId,
        'submissionDate': Timestamp.now(),
        'submissionImageBase64': base64Image,
      });

      setState(() {
        uploadedFileBase64 = base64Image;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Task submitted successfully")));
    } catch (e, stack) {
      print("🔥 ERROR during upload: $e");
      print("🔥 Stack trace: $stack");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Submission failed: $e")));
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    if (taskData == null) {
      return Scaffold(
        appBar: AppBar(title: Text("Task Details")),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String title = taskData!['taskTitle'] ?? 'No Title';
    String description = taskData!['taskDescription'] ?? 'No Description';
    DateTime dueDate = (taskData!['dueDate'] as Timestamp).toDate().toLocal();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: Colors.deepPurple,
  iconTheme: IconThemeData(color: Colors.white), // 🔹 This makes the back arrow white
  title: Text(
    "Task Details",
    style: TextStyle(color: Colors.white),
  ),
),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔶 Professional Card UI
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              color: Colors.white,
              shadowColor: Colors.grey.withOpacity(0.3),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Task Title",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      title,
                      style: TextStyle(fontSize: 18),
                    ),
                    Divider(height: 30, thickness: 1.2),

                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(fontSize: 16),
                    ),
                    Divider(height: 30, thickness: 1.2),

                    Text(
                      "Due Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      DateFormat('yyyy-MM-dd').format(dueDate),
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            // 🔶 Screenshot Picker Section
            Text("Choose Screenshot", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.attach_file, color: Colors.white),
              label: Text(selectedFile == null ? 'Pick Screenshot' : 'Change Screenshot' ,
              style: TextStyle(color: Colors.white),
              ),
              onPressed: pickFile,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),
            if (selectedFile != null)
              Text(
                "Selected: ${selectedFile!.path.split('/').last}",
                style: TextStyle(color: Colors.green),
              ),

            SizedBox(height: 20),

            // 🔶 Submit Button
            ElevatedButton(
              onPressed: isSubmitting ? null : submitTask,
              child: isSubmitting
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text("Submit Task" ,
                  style: TextStyle(color: Colors.white),
                  ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            ),

            // 🔶 Submitted Screenshot Preview
            if (uploadedFileBase64 != null) ...[
              SizedBox(height: 20),
              Text("Screenshot submitted successfully!", style: TextStyle(color: Colors.green)),
              SizedBox(height: 20),
              Image.memory(base64Decode(uploadedFileBase64!)),
            ],
          ],
        ),
      ),
    );
  }
}
