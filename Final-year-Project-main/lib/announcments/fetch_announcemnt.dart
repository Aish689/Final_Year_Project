import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Fetch Announcements with formatted date and time
  Stream<List<Map<String, dynamic>>> fetchAnnouncements() {
    return _db.collection('announcements')
      .orderBy('createdAt', descending: true) // Fetch latest first
      .limit(10) // Limit to latest 10 announcements
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
          
          final DateTime fallbackDate = DateTime(2000, 1, 1); // Default value
          final date = createdAt != null ? DateFormat('yyyy-MM-dd').format(createdAt) : DateFormat('yyyy-MM-dd').format(fallbackDate);
          final time = createdAt != null ? DateFormat('HH:mm:ss').format(createdAt) : DateFormat('HH:mm:ss').format(fallbackDate);

          return {
            'title': data['title'] ?? 'No Title',
            'content': data['content'] ?? 'No Content',
            'time': time,
            'date': date,
          };
        }).toList();
      });
  }
}
