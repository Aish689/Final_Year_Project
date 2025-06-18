import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_check_hours.dart';

class CheckHoursScreen extends StatefulWidget {
  @override
  _CheckHoursScreenState createState() => _CheckHoursScreenState();
}

class _CheckHoursScreenState extends State<CheckHoursScreen> {
  String? selectedEmployeeId; // Store the employee id
  String? selectedEmployeeName; // Store the employee name
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: Image.asset('assets/images/top.jpeg',
                width: MediaQuery.of(context).size.width),
          ),
          Positioned(
            bottom: 0,
            child: Image.asset('assets/images/myimage.jpeg',
                width: MediaQuery.of(context).size.width),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Image.asset('assets/images/pic.png', width: 24, height: 24),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(width: 40),
                    Text("Check Hours", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ],
                ),
                Spacer(),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance.collection('staff').get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Error loading staff members"));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No staff members found"));
                    }

                    List<DropdownMenuItem<String>> dropdownItems =
                        snapshot.data!.docs.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc.id, // Use employee ID for value
                        child: Text(doc['name'] ?? 'Unknown'),
                      );
                    }).toList();

                    return DropdownButtonFormField<String>(
                      value: selectedEmployeeId,
                      items: dropdownItems,
                      onChanged: (value) {
                        setState(() {
                          selectedEmployeeId = value;
                          selectedEmployeeName = snapshot.data!.docs
                              .firstWhere((doc) => doc.id == value)
                              .get('name'); // Fetch the name by matching the id
                        });
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: "Select Staff Member",
                      ),
                    );
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: selectedDate == null
                        ? "Select Date"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    if (selectedEmployeeId == null || selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select both an employee and a date")),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminCheckHours(
                            employeeId: selectedEmployeeId!,
                            employeeName: selectedEmployeeName!,
                            selectedDate: selectedDate!,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  child: Text("Check", style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
                Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
