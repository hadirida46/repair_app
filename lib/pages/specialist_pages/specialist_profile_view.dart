import 'package:flutter/material.dart';
import 'main_page.dart';
import '/pages/chat.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../../constants.dart';

const Color primaryOrange = Color(0xFFFF9800);
const Color darkBlue = Colors.indigo;
const Color lightGrey = Colors.grey;

class SpecialistProfileView extends StatefulWidget {
  final Map<String, String> specialist;
  final int reportId;

  const SpecialistProfileView({
    super.key,
    required this.specialist,
    required this.reportId,
  });

  @override
  State<SpecialistProfileView> createState() => _SpecialistProfileViewState();
}

class _SpecialistProfileViewState extends State<SpecialistProfileView> {
  List<String> feedbacks = [];
  bool isLoadingFeedback = true;

  @override
  void initState() {
    super.initState();
    fetchFeedbacks();
  }

  Future<void> fetchFeedbacks() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final specialistId = widget.specialist['id'];

    if (token == null || specialistId == null) return;

    final url = Uri.parse('$baseUrl/feedback/specialist/$specialistId');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> feedbackJson =
          json.decode(response.body)['feedbacks'];
      setState(() {
        feedbacks = feedbackJson.map((f) => f['feedback'] as String).toList();
        isLoadingFeedback = false;
      });
    } else {
      setState(() {
        isLoadingFeedback = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        '${widget.specialist['first_name'] ?? ''} ${widget.specialist['last_name'] ?? ''}'
            .trim();
    final String email = widget.specialist['email'] ?? '';
    final String specialty = widget.specialist['specialization'] ?? '';
    final String? profileImage = widget.specialist['profile_image'];
    final String? bio = widget.specialist['bio'];

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          specialty,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
        elevation: 2, // Subtle shadow
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: lightGrey,
                child: ClipOval(
                  child:
                      profileImage != null && profileImage.isNotEmpty
                          ? Image.network(
                            profileImage,
                            fit: BoxFit.cover,
                            width: 140,
                            height: 140,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/profile_pic.png',
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                              );
                            },
                          )
                          : Image.asset(
                            'assets/profile_pic.png',
                            fit: BoxFit.cover,
                            width: 140,
                            height: 140,
                          ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (email.isNotEmpty)
              Text(email, style: TextStyle(color: lightGrey, fontSize: 16)),
            const SizedBox(height: 24),

            // Bio Section
            _buildSection('About', bio, Icons.info_outline),
            const SizedBox(height: 20),

            // Feedback Section
            _sectionTitle('Patient Feedback', Icons.message_outlined),
            const SizedBox(height: 12),
            isLoadingFeedback
                ? const Center(child: CircularProgressIndicator())
                : feedbacks.isEmpty
                ? const Text(
                  'No feedback available yet.',
                  style: TextStyle(color: lightGrey),
                  textAlign: TextAlign.center,
                )
                : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: feedbacks.length,
                  separatorBuilder:
                      (context, index) =>
                          const Divider(indent: 10, endIndent: 10),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        feedbacks[index],
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
            const SizedBox(height: 30),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => Chat(
                                receiverId: int.parse(widget.specialist['id']!),
                                receiverName:
                                    '${widget.specialist['first_name']} ${widget.specialist['last_name']}',
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Chat',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final storage = FlutterSecureStorage();
                      final token = await storage.read(key: 'auth_token');
                      final specialistId = widget.specialist['id'];

                      if (token == null || specialistId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Missing token or specialist ID'),
                          ),
                        );
                        return;
                      }

                      final url = Uri.parse(
                        '$baseUrl/reports/${widget.reportId}/assign',
                      );

                      final response = await http.post(
                        url,
                        headers: {
                          'Authorization': 'Bearer $token',
                          'Content-Type': 'application/json',
                        },
                        body: json.encode({
                          'specialist_id': int.parse(specialistId),
                        }),
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
                            builder:
                                (_) =>
                                    const SpecialistMainPage(initialIndex: 1),
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
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    icon: const Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Select',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String? body, IconData icon) {
    if (body == null || body.trim().isEmpty) return const SizedBox();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title, icon),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryOrange),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: darkBlue,
          ),
        ),
      ],
    );
  }
}
