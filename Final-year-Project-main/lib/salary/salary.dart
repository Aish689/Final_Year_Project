import 'package:flutter/material.dart';
import 'package:soricc/salary/setting.dart';

import '../attendence/attendenceHomeScreen.dart';
import '../attendence/attendence_page.dart';

class SalaryScreen extends StatelessWidget {
  final int baseSalary = 50000; // Base salary of the employee
  final int totalAttendanceDays = 25; // Total attendance days
  final int totalWorkingDays = 30; // Total working days in a month
  final double bonusPercentage = 0.20; // Bonus percentage (20%)

  @override
  Widget build(BuildContext context) {
    // Calculate attendance percentage
    double attendancePercentage = totalAttendanceDays / totalWorkingDays;

    // Calculate bonus based on attendance
    double bonus = baseSalary * (attendancePercentage >= 0.83 ? bonusPercentage : 0); // 83% or more attendance earns 20% bonus
    double totalSalary = baseSalary + bonus;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salary Details',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          DropdownButton<String>(
            underline: Container(),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            items: ['November', 'October', 'September']
                .map((String value) => DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            ))
                .toList(),
            onChanged: (_) {},
          ),
        ],
        backgroundColor: Color(0xFF4B2C83),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Salary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '₹ 50,000',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4B2C83)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Salary Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Basic Pay'),
              trailing: const Text('₹ 30,000'),
            ),
            ListTile(
              title: const Text('Allowances'),
              trailing: const Text('₹ 15,000'),
            ),
            ListTile(
              title: const Text('Deductions'),
              trailing: const Text('₹ 5,000'),
            ),
            const Divider(),
            ListTile(
              title: const Text(
                'Net Pay',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              trailing: Text(
                '₹ ${totalSalary.toStringAsFixed(2)}', // Displaying the total salary with bonus
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              child: const Text(
                'Generate Payslip',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Color(0xFF4B2C83),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Salary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        selectedItemColor: Color(0xFF4B2C83),
        unselectedItemColor: Colors.grey,
        currentIndex: 2, // Highlight "Salary" tab
        onTap: (index) {
          // Navigate based on the selected index
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DashboardAttendanceScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AttendanceHomeScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsScreen()),
            );
          }
        },
      ),
    );
  }
}
 