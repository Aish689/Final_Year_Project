import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
        name: "Hajra Asghar",
        message:
            "Hi! Welcome to your new workspace! Here are the details for your new Slack workspace, Soric Software and Tech Company.",
        date: "19/1/2024",
        image: "assets/images/avatar1.png",
        section: "New"),
    NotificationItem(
        name: "Hafsa Zainab",
        message:
            "Hi! Welcome to your new workspace! Here are the details for your new Slack workspace, Soric Software and Tech Company.",
        date: "19/1/2024",
        image: "assets/images/avatar2.png",
        section: "New"),
    NotificationItem(
        name: "Ali Sani",
        message:
            "Hi! Welcome to your new workspace! Here are the details for your new Slack workspace, Soric Software and Tech Company.",
        date: "19/1/2024",
        image: "assets/images/avatar3.png",
        section: "New"),
    NotificationItem(
        name: "M Jaffar",
        message:
            "Hi! Welcome to your new workspace! Here are the details for your new Slack workspace, Soric Software and Tech Company.",
        date: "18/1/2024",
        image: "assets/images/avatar4.png",
        section: "Yesterday"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notification",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: ListView(
          children: [
            _buildSection("New"),
            _buildNotificationList("New"),
            _buildSection("Yesterday"),
            _buildNotificationList("Yesterday"),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildNotificationList(String section) {
    return Column(
      children: notifications
          .where((notif) => notif.section == section)
          .map((notif) => _buildNotificationItem(notif))
          .toList(),
    );
  }

  Widget _buildNotificationItem(NotificationItem item) {
    return Card(
      elevation: 0,
      color: Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(item.image),
          radius: 25,
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.message,
              style: TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Text(
              item.date,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationItem {
  final String name;
  final String message;
  final String date;
  final String image;
  final String section;

  NotificationItem({
    required this.name,
    required this.message,
    required this.date,
    required this.image,
    required this.section,
  });
}
