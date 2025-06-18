import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SidebarDashboardScreen extends StatelessWidget {
  final List<DashboardItem> items = [
    DashboardItem("Users", Icons.people, UsersScreen()),
    DashboardItem("Services", Icons.settings, ServicesScreen()),
    DashboardItem("Reports", Icons.bar_chart, ReportsScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Company Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert), // Three-dot menu icon
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Opens the sidebar
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF4B2C83)),
              child: Text(
                'Dashboard Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ...items.map((item) {
              return ListTile(
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => item.screen),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Select an item from the menu',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}

// Dashboard Item Class
class DashboardItem {
  final String title;
  final IconData icon;
  final Widget screen;

  DashboardItem(this.title, this.icon, this.screen);
}

// Placeholder screens
class UsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Users')),
      body: Center(child: Text('Users Section')),
    );
  }
}

class ServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Services')),
      body: Center(child: Text('Services Section')),
    );
  }
}

class ReportsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Center(child: Text('Reports Section')),
    );
  }
}
