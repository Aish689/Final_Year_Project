import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createAnnouncement(
      String title, String content, String targetAudience, DateTime? expirationDate) async {
    try {
      await _db.collection('announcements').add({
        'title': title,
        'content': content,
        'targetAudience': targetAudience,
        'expirationDate': expirationDate != null ? Timestamp.fromDate(expirationDate) : null,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating announcement: $e');
      throw Exception('Failed to create announcement');
    }
  }
}
