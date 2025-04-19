import 'package:flutter/material.dart';
import 'home.dart'; // Import home.dart
import 'my_reports.dart'; // Import my_reports.dart
import 'create_report.dart'; // Import create_report.dart
import 'chat_list.dart'; // Import chat_list.dart
import '/widgets/bottom_nav_bar.dart'; // Assuming you have a BottomNavBar widget

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages to navigate between
  final List<Widget> _pages = [
    const Home(), // Replace with the actual Home page widget
    const MyReports(), // Replace with the actual My Reports page widget
    const CreateReport(), // Replace with the actual Create Report page widget
    const ChatList(), // Replace with the actual Chat List page widget
  ];

  // Update selected page when bottom navigation item is tapped
  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _pages[_selectedIndex], // Display the page based on the selected index
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped, // Update the page when the bottom nav is tapped
      ),
    );
  }
}
