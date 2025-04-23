import 'package:flutter/material.dart';
import 's_home.dart';
import 's_create_report.dart';
import 'jobs.dart';
import 'chat_list.dart';
import 's_profile.dart';
import '/widgets/s_bottom_nav_bar.dart'; 

class SpecialistMainPage extends StatefulWidget {
  const SpecialistMainPage({Key? key}) : super(key: key);

  @override
  State<SpecialistMainPage> createState() => _SpecialistMainPageState();
}

class _SpecialistMainPageState extends State<SpecialistMainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SpecialistHome(),              
    const SCreateReport(),     
    const SpecialistJobs(),         
    const ChatList(),         
    const SpecialistProfile(),           
  ];

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
