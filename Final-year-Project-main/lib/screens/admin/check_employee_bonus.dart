/*import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:soricc/screens/admin/employee_reward.dart';
 // Updated import path

class CheckEmployeeBonus extends StatefulWidget {
  @override
  _CheckEmployeeBonus createState() => _CheckEmployeeBonus();
}

class _CheckEmployeeBonus extends State<CheckEmployeeBonus> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/top.jpeg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              Text(
                'Employee Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employee...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('staff').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                      var employees = snapshot.data!.docs;

                      var filteredEmployees = employees.where((doc) {
                        String name = doc['name'].toString().toLowerCase();
                        return name.contains(searchQuery);
                      }).toList();

                      return ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(10),
                        itemCount: filteredEmployees.length,
                        itemBuilder: (context, index) {
                          var employee = filteredEmployees[index];
                          String name = employee['name'];
                          String userId = employee.id;

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                child: Text(name[0].toUpperCase()),
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                              title: Text(
                                name,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                "ID: $userId",
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Get.to(() =>  EmployeeFinalDecisionScreen(userId: userId));
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              Image.asset(
                'assets/images/myimage.jpeg',
                width: double.infinity,
                height: 100,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'employee_reward.dart'; // Make sure this file contains EmployeeFinalDecisionScreen

class CheckEmployeeBonus extends StatefulWidget {
  @override
  _CheckEmployeeBonus createState() => _CheckEmployeeBonus();
}

class _CheckEmployeeBonus extends State<CheckEmployeeBonus> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                'assets/images/top.jpeg',
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
              const Text(
                'Employee Screen',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employee...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('staff').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var employees = snapshot.data!.docs;
                var filteredEmployees = employees.where((doc) {
                  String name = doc['name'].toString().toLowerCase();
                  return name.contains(searchQuery);
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10),
                  itemCount: filteredEmployees.length,
                  itemBuilder: (context, index) {
                    var employee = filteredEmployees[index];
                    String name = employee['name'];
                    String userId = employee.id;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          child: Text(name[0].toUpperCase()),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "ID: $userId",
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Get.to(() => EmployeeFinalDecisionScreen(userId: userId));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Image.asset(
            'assets/images/myimage.jpeg',
            width: double.infinity,
            height: 100,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}

