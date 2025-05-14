import 'package:flutter/material.dart';
import '../../widgets/multiline_text_field.dart';
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const primaryOrange = Color(0xFFFF9800);

class FeedbackPage extends StatefulWidget {
  final int reportId;
  final int specialistId;

  const FeedbackPage({
    super.key,
    required this.reportId,
    required this.specialistId,
  });

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _feedbackController = TextEditingController();
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  void _submitFeedback() async {
    final feedback = _feedbackController.text.trim();
    if (feedback.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your feedback.'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      final response = await submitFeedbackToBackend(
        reportId: widget.reportId,
        specialistId: widget.specialistId,
        comment: feedback,
      );

      if (response != null && response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Thank you for your feedback!'),
            backgroundColor: primaryOrange,
          ),
        );
        _feedbackController.clear();
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to submit feedback. ${response?.body ?? 'Please try again.'}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<http.Response?> submitFeedbackToBackend({
    required int reportId,
    required int specialistId,
    required String comment,
  }) async {
    final token = await storage.read(key: 'auth_token');
    final url = Uri.parse('$baseUrl/feedback');

    // Send the request
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'specialist_id': specialistId, 'comment': comment}),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
        backgroundColor: primaryOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'We’d love to hear your feedback!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CustomMultilineTextField(
              controller: _feedbackController,
              label: 'Type your feedback here...',
              icon: Icons.feedback_outlined,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Submit',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
