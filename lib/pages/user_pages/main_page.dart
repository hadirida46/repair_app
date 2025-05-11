import 'package:flutter/material.dart';
import 'home.dart';
import 'my_reports.dart';
import 'create_report.dart';
import '../chat_list.dart';
import '/widgets/bottom_nav_bar.dart';
import 'profile.dart';

class MainPage extends StatefulWidget {
  final int initialIndex;

  const MainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late int _selectedIndex;
  final List<Widget> _pages = [
    const Home(),
    const MyReports(),
    const CreateReport(),
    const ChatList(),
    const UserProfile(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}
