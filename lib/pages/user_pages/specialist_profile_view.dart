import 'package:flutter/material.dart';
import 'main_page.dart';

const Color primaryOrange = Color(0xFFFF9800);

class SpecialistProfileView extends StatelessWidget {
  final Map<String, String> specialist;

  const SpecialistProfileView({super.key, required this.specialist});

  @override
  Widget build(BuildContext context) {
    final String name = specialist['name'] ?? 'Specialist';
    final String specialty = specialist['specialty'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'The $specialty $name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 60,
                backgroundImage: AssetImage('assets/profile_pic.png'),
                backgroundColor: Colors.grey,
              ),
              const SizedBox(height: 20),
              sectionTitle('Bio'),
              sectionBody(specialist['bio']),
              const SizedBox(height: 20),
              sectionTitle('Feedbacks'),
              sectionBody(
                '• Great service!\n• Quick and professional.\n• Highly recommended.',
              ),
              const SizedBox(height: 20),
              sectionTitle('His Work'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset('assets/electricity.png'),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Navigate to User's main page after selecting the specialist
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const MainPage()),
              (route) => false,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo[900],
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          icon: const Icon(Icons.check_circle, color: Colors.white),
          label: const Text(
            'Select This Specialist',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: primaryOrange,
        ),
      ),
    );
  }

  Widget sectionBody(String? text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text ?? 'N/A', style: const TextStyle(fontSize: 16)),
    );
  }
}
