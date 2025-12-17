import 'package:early_application_1/admin/admin_dashboard.dart';
import 'package:early_application_1/admin/admin_users.dart';
import 'package:early_application_1/adminrep.dart';
import 'package:early_application_1/admin/admin_signin.dart';
import 'package:flutter/material.dart';

class AdminBasePage extends StatefulWidget {
  final int initialIndex; // optional initial tab
  const AdminBasePage({this.initialIndex = 0, super.key});

  @override
  _AdminBasePageState createState() => _AdminBasePageState();
}

class _AdminBasePageState extends State<AdminBasePage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    AdminDashboard(),
    UsersPage(),
    ReportsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _logout() {
    // Navigate to AdminSignInPage and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AdminSignInPage()),
      (route) => false, // remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 183, 224, 19),
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _logout,
          tooltip: 'Logout',
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 183, 224, 19),
        unselectedItemColor: Colors.grey,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}
