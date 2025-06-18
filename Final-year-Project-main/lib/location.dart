import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';



class AttendanceScreenlocation extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreenlocation> {
  String message = 'Press buttons to set or mark attendance.';
  bool isLoading = false;

  static const double allowedRadiusInMeters = 100;

  // Step 1: Save current location as fixed attendance location in Firestore
  Future<void> setAttendanceLocation() async {
    setState(() {
      isLoading = true;
      message = 'Getting current location...';
    });

    try {
      Position position = await _determinePosition();

      await FirebaseFirestore.instance
          .collection('settings')
          .doc('attendance_location')
          .set({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      setState(() {
        message =
            'Attendance location saved at (${position.latitude}, ${position.longitude})';
      });
    } catch (e) {
      setState(() {
        message = 'Error setting location: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Step 2: Mark attendance if user is within allowed radius
  Future<void> markAttendance() async {
    setState(() {
      isLoading = true;
      message = 'Checking location for attendance...';
    });

    try {
      Position userPosition = await _determinePosition();

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('attendance_location')
          .get();

      if (!doc.exists) {
        setState(() {
          message =
              'Attendance location is not set. Please set it first using "Set Attendance Location" button.';
        });
        return;
      }

      double officeLat = doc['latitude'];
      double officeLng = doc['longitude'];

      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        officeLat,
        officeLng,
      );

      if (distanceInMeters <= allowedRadiusInMeters) {
        // Here you would save attendance record in Firestore or your backend
        setState(() {
          message = 'Attendance marked successfully! (Distance: ${distanceInMeters.toStringAsFixed(2)} m)';
        });
      } else {
        setState(() {
          message =
              'Too far from attendance location! Distance: ${distanceInMeters.toStringAsFixed(2)} meters.';
        });
      }
    } catch (e) {
      setState(() {
        message = 'Error marking attendance: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Helper to request permissions and get current position
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Location'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ElevatedButton(
                onPressed: isLoading ? null : setAttendanceLocation,
                child: Text('Set Attendance Location (Where I am sitting)'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : markAttendance,
                child: Text('Mark Attendance'),
              ),
              SizedBox(height: 40),
              isLoading
                  ? CircularProgressIndicator()
                  : Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
