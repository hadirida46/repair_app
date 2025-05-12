import 'package:flutter/material.dart';
import 'main_page.dart';
import '/pages/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../constants.dart';

const Color primaryOrange = Color(0xFFFF9800);

class SpecialistProfileView extends StatelessWidget {
  final Map<String, String> specialist;
  final int reportId;

  const SpecialistProfileView({
    super.key,
    required this.specialist,
    required this.reportId,
  });

  @override
  Widget build(BuildContext context) {
    final String name =
        '${specialist['first_name'] ?? ''} ${specialist['last_name'] ?? ''}'
            .trim();
    final String email = specialist['email'] ?? '';
    final String specialty = specialist['specialization'] ?? '';
    final String? profileImage = specialist['profile_image'];
    final String? bio = specialist['bio'];

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
              backgroundColor: Colors.grey.shade300,
              child: ClipOval(
                child:
                    profileImage != null && profileImage.isNotEmpty
                        ? Image.network(
                          profileImage,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset(
                              'assets/profile_pic.png',
                              fit: BoxFit.cover,
                              width: 120,
                              height: 120,
                            );
                          },
                        )
                        : Image.asset(
                          'assets/profile_pic.png',
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (email.isNotEmpty)
              Text(email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            buildSection('Bio', bio),
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Chat()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                minimumSize: const Size(double.infinity, 45),
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
            ElevatedButton.icon(
              onPressed: () async {
                final storage = FlutterSecureStorage();
                final token = await storage.read(key: 'auth_token');
                final specialistId = specialist['id'];

                if (token == null || specialistId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Missing token or specialist ID'),
                    ),
                  );
                  return;
                }

                final url = Uri.parse('$baseUrl/reports/$reportId/assign');

                final response = await http.post(
                  url,
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  body: json.encode({'specialist_id': int.parse(specialistId)}),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Specialist assigned successfully!'),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SpecialistMainPage(initialIndex: 1),
                    ),
                  );
                } else {
                  final error = json.decode(response.body);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${error['message'] ?? 'Failed to assign specialist'}',
                      ),
                    ),
                  );
                }
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
