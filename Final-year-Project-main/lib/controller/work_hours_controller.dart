import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class WorkHoursController extends GetxController {
  var selectedDate = ''.obs;
  var hours = ''.obs;
  var type = ''.obs;
  var brief = ''.obs;
  var employeeName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateFormat('dd/MM/yyyy').format(DateTime.now());
    loadEmployeeName();
  }

  void loadEmployeeName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final doc = await FirebaseFirestore.instance.collection('staff').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        employeeName.value = doc['name'] ?? 'Unknown';
      }
    }
  }

  bool isValidForm() {
    return hours.value.isNotEmpty && type.value.isNotEmpty && brief.value.isNotEmpty;
  }

 Future<void> submitToFirestore(WorkHoursController controller) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || !controller.isValidForm()) {
    Get.snackbar("Error", "Please fill out all fields and ensure you're logged in.");
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('work_hours').add({
      'userId': uid,  // Corrected this line
      'date': Timestamp.now(),
      'brief': controller.brief.value,
      'type': controller.type.value,
      'hours': controller.hours.value,
    });

    Get.snackbar("Success", "Work hours submitted successfully!");

    // Reset form fields
    controller.hours.value = '';
    controller.type.value = '';
    controller.brief.value = '';
  } catch (e) {
    Get.snackbar("Error", "Failed to submit: $e");
  }
}

}
