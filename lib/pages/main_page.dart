import 'package:flutter/material.dart';
import 'home.dart';
import 'my_reports.dart';
import 'create_report.dart';
import 'chat_list.dart'; 
import '/widgets/bottom_nav_bar.dart'; 

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages to navigate between
  final List<Widget> _pages = [
    const Home(),
    const MyReports(),
    const CreateReport(),
    const ChatList(),
  ];

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
