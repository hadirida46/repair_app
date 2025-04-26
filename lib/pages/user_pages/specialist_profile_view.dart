import 'package:flutter/material.dart';
import 'main_page.dart';
import '/pages/chat.dart';

const Color primaryOrange = Color(0xFFFF9800);

class SpecialistProfileView extends StatelessWidget {
  final Map<String, String> specialist;

  const SpecialistProfileView({super.key, required this.specialist});

  @override
  Widget build(BuildContext context) {
    final String name = specialist['name'] ?? 'Specialist';
    final String specialty = specialist['specialty'] ?? '';

    return Scaffold(
      backgroundColor: Colors.grey[100], // Set background color here
      appBar: AppBar(
        title: Text(
          '$specialty $name',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: const AssetImage('assets/profile_pic.png'),
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 20),
            buildSection('Bio', specialist['bio']),
            const SizedBox(height: 20),
            buildSection(
              'Feedbacks',
              '• Great service!\n• Quick and professional.\n• Highly recommended.',
            ),
            const SizedBox(height: 20),
            sectionTitle('His Work'),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.asset('assets/electricity.png'),
            ),
            const SizedBox(height: 30),

            // Chat button (smaller)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Chat()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                minimumSize: const Size(double.infinity, 45), // Smaller height
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
              label: const Text(
                'Chat with Specialist',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            const SizedBox(height: 20),

            // Select Specialist button (with icon)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MainPage(initialIndex: 1),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Select This Specialist',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, String? body) {
    if (body == null || body.trim().isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(title),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: primaryOrange,
      ),
    );
  }
}
