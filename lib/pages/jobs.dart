import 'package:flutter/material.dart';

class SpecialistJobs extends StatelessWidget {
  const SpecialistJobs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Center(
        child: Text('Pending and Ongoing Jobs', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
