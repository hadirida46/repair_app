import 'package:flutter/material.dart';
import 'home.dart';
import 'create_report.dart';
import 'jobs.dart';
import '../chat_list.dart';
import 'profile.dart';
import '/widgets/s_bottom_nav_bar.dart';

class SpecialistMainPage extends StatefulWidget {
  final int initialIndex;

  const SpecialistMainPage({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<SpecialistMainPage> createState() => _SpecialistMainPageState();
}

class _SpecialistMainPageState extends State<SpecialistMainPage> {
  late int _selectedIndex;

  final List<Widget> _pages = [
    const SpecialistHome(),
    const SCreateReport(),
    const SpecialistJobs(),
    const ChatList(),
    const SpecialistProfile(),
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
