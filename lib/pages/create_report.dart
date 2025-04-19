import 'package:flutter/material.dart';

class CreateReport extends StatelessWidget {
  const CreateReport({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Report'),
        backgroundColor: Colors.indigo[900],
      ),
      body: const Center(
        child: Text('Form to create a report will appear here'),
      ),
    );
  }
}
