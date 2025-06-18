import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controller/work_hours_controller.dart';

class WorkHoursScreen extends StatelessWidget {
  final WorkHoursController controller = Get.put(WorkHoursController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false, // ✅ Prevent keyboard from pushing content
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: 20), // Optional spacing
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: 250,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: TopWavePainter(),
                        ),
                      ),
                      Positioned(
                        top: 70,
                        left: 20,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(Icons.arrow_back, color: Colors.black, size: 30),
                        ),
                      ),
                      const Positioned(
                        top: 70,
                        right: 60,
                        child: Text(
                          "Justify Your Work Hours",
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 120,
                        left: 20,
                        child: Obx(() => Text(
                          '${controller.selectedDate.value}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        )),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFBDB1D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              onChanged: (value) => controller.hours.value = value,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Enter Hours',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Color(0xFFBDB1D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: TextField(
                              onChanged: (value) => controller.type.value = value,
                              decoration: InputDecoration(
                                hintText: 'Enter Type',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Container(
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets.all(10),
                      child: TextField(
                        onChanged: (value) => controller.brief.value = value,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Brief here...',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: GestureDetector(
                      onTap: () async {
                        if (controller.isValidForm()) {
                          try {
                            final uid = FirebaseAuth.instance.currentUser?.uid;
                            if (uid != null) {
                              await FirebaseFirestore.instance.collection('work_hours').add({
                                'userId': uid,
                                'date': Timestamp.now(),
                                'brief': controller.brief.value,
                                'type': controller.type.value,
                                'hours': controller.hours.value,
                              });

                              controller.hours.value = '';
                              controller.type.value = '';
                              controller.brief.value = '';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Form Submitted Successfully")),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("User not logged in")),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Failed to Submit: $e")),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Please fill out all fields")),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                        child: Center(
                          child: Text(
                            'Add +',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // ✅ Bottom image fixed and not affected by keyboard
          Image.asset(
            'assets/images/bottom.jpeg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 150, // Optional: fixed height
          ),
        ],
      ),
    );
  }
}

// Custom painter for the top wave
class TopWavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = Color(0xFFC5B4E3);
    var path = getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

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
