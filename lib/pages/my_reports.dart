import 'package:flutter/material.dart';

class MyReports extends StatelessWidget {
  const MyReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.indigo[900],
      ),
      body: const Center(child: Text('List of your reports will appear here')),
    );
  }
}
