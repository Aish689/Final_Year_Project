import 'package:flutter/material.dart';
import '../announcments/fetch_announcemnt.dart';
 // Correct import for FirestoreService

class AnnouncementsPage extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.fetchAnnouncements(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final announcements = snapshot.data!;
          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final announcement = announcements[index];
              return ListTile(
                title: Text(announcement['title']),
                subtitle: Text(announcement['content']),
              );
            },
          );
        },
      ),
    );
  }
}
