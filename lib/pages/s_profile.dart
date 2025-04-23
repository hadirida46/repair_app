import 'package:flutter/material.dart';

class SpecialistProfile extends StatelessWidget {
  const SpecialistProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Center(
        child: Text('Specialist Profile', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
