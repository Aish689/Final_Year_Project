import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soricc/screens/dashboard.dart';
import 'package:soricc/screens/justifiyHours.dart';

class ProfilePage extends StatefulWidget {
  final User user;
   
  ProfilePage({required this.user});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  bool _isSaving = false;
  String? _name;
  String? _imageUrl;
  File? _imageFile; // To store the profile image URL

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data (Name + Profile Picture)
 Future<void> _fetchUserData() async {
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('staff')
        .doc(widget.user.uid)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>; // Ensure proper casting

      setState(() {
        _name = data['name'] ?? 'No name';
        _imageUrl = data['profileImage'] ?? null;
      });
    } else {
      setState(() {
        _name = 'No name found';
      });
    }
  } catch (e) {
    setState(() {
      _name = 'Error fetching name';
    });
    debugPrint('Error fetching user name: $e');
  }
}


  // Upload Image to Firebase Storage
Future<void> _pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) return;

      final directory = await getApplicationDocumentsDirectory();
      final localImagePath = File('${directory.path}/profile_image.jpg');

      // Save the selected image locally
      final savedImage = await File(pickedFile.path).copy(localImagePath.path);

      setState(() {
        _imageFile = savedImage;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image saved successfully!')),
      );
    } catch (e) {
      debugPrint('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving image')),
      );
    }
  }

  Future<void> _saveProfile() async {
  if (_expertiseController.text.isEmpty ||
      _experienceController.text.isEmpty ||
      _hoursController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please complete all fields!')),
    );
    return;
  }

  setState(() {
    _isSaving = true;
  });

  try {
    // Debug: Print data before saving
    print('Saving data to Firestore:');
    print({
      'name': _name ?? 'No name',
      'email': widget.user.email ?? 'No email',
      'expertise': _expertiseController.text,
      'experience': _experienceController.text,
      'workingHours': _hoursController.text,
      'jobTitle': _jobTitleController.text,
      'department': _departmentController.text,
      'profileImage': _imageUrl ?? '',
    });

    await FirebaseFirestore.instance.collection('staff').doc(widget.user.uid).set({
      'name': _name ?? 'No name',
      'email': widget.user.email ?? 'No email',
      'expertise': _expertiseController.text,
      'experience': _experienceController.text,
      'workingHours': _hoursController.text,
      'jobTitle': _jobTitleController.text,
      'department': _departmentController.text,
      'profileImage': _imageUrl ?? '',
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Profile saved successfully!')),
    );

    // Debug: Confirm save operation
    print('Profile data successfully saved to Firestore');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => DashboardPage()),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to save profile: $e')),
    );

    print('Error saving profile: $e');
  } finally {
    setState(() {
      _isSaving = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              
              // Profile Image Section
              GestureDetector(
              onTap: _pickAndSaveImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                child: _imageFile == null
                    ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[700])
                    : null,
              ),
            ),
              SizedBox(height: 16),

              Text('Name: ${_name ?? 'Loading...'}'),
              SizedBox(height: 8),
              Text('Email: ${widget.user.email ?? 'No email'}'),
              SizedBox(height: 16),

              // Input Fields
              TextField(
                controller: _expertiseController,
                decoration: InputDecoration(labelText: 'Expertise'),
              ),

              TextField(
                controller: _experienceController,
                decoration: InputDecoration(labelText: 'Experience'),
              ),
              TextField(
                controller: _hoursController,
                decoration: InputDecoration(labelText: 'Working Hours'),
                keyboardType: TextInputType.number,
              ),
              TextField(
  controller: _jobTitleController,
  decoration: InputDecoration(labelText: 'Job Title'),
           ),
               TextField(
             controller: _departmentController,
             decoration: InputDecoration(labelText: 'Department'),
            ),
              SizedBox(height: 16),

              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: Text('Save'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
