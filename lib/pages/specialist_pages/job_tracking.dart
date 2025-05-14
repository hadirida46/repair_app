import 'dart:io';
import 'package:flutter/material.dart';
import '../chat.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JobTrackingPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobTrackingPage({super.key, required this.job});

  @override
  State<JobTrackingPage> createState() => _JobTrackingState();
}

class _JobTrackingState extends State<JobTrackingPage> {
  List<dynamic> _existingProgress = [];
  @override
  void initState() {
    super.initState();
    _loadExistingProgress();
  }

  Future<void> _loadExistingProgress() async {
    final progressData = await _fetchProgressUpdates();
    setState(() {
      _existingProgress = progressData;
    });
    _originalImages.clear();
    _commentControllers.clear();
    _specialistComments.clear();
    _commentAdded.clear();

    for (var item in _existingProgress) {
      _originalImages.add(item['image_url']);

      _progressIds.add(item['id']);

      _specialistComments.add(item['specialist_comment'] ?? '');
    }
    _syncCommentAndSpecialistLists();
  }

  Future<List<dynamic>> _fetchProgressUpdates() async {
    final reportId = widget.job['id'];
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User is not authenticated'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }

    final uri = Uri.parse('$baseUrl/reports/$reportId/progress');

    try {
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData is Map && responseData.containsKey('data')) {
          return responseData['data'] as List<dynamic>;
        } else {
          print('Error: Invalid response format - $responseData');
          _showErrorSnackBar('Failed to load progress updates.');
          return [];
        }
      } else {
        print('Failed to fetch progress updates: ${response.statusCode}');
        _showErrorSnackBar('Failed to load progress updates.');
        return [];
      }
    } catch (error) {
      print('Error fetching progress updates: $error');
      _showErrorSnackBar('Failed to load progress updates.');
      return [];
    }
  }

  static const Color primaryOrange = Color(0xFFFFA726);

  final List<dynamic> _originalImages = [];
  final List<TextEditingController> _commentControllers = [];
  final List<String> _specialistComments = [];
  final List<bool> _commentAdded = [];
  final List<int> _progressIds = [];

  @override
  void didUpdateWidget(covariant JobTrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCommentAndSpecialistLists();
  }

  void _syncCommentAndSpecialistLists() {
    while (_commentControllers.length < _originalImages.length) {
      _commentControllers.add(TextEditingController());
      _specialistComments.add('');
      _commentAdded.add(false);
    }
    while (_commentControllers.length > _originalImages.length) {
      _commentControllers.last.dispose();
      _commentControllers.removeLast();
      _specialistComments.removeLast();
      _commentAdded.removeLast();
    }
  }

  @override
  void dispose() {
    for (final controller in _commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isPickingImage = false;

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: primaryOrange,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildImageGallery() {
    if (_originalImages.isEmpty) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: const Center(child: Text('No progress updates yet.')),
      );
    }

    return Column(
      children:
          _originalImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;

            Widget imageWidget;

            if (image is String && image.isNotEmpty) {
              imageWidget = Image.network(
                image,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.cover,
              );
            } else if (image is File) {
              imageWidget = Image.file(
                image,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                fit: BoxFit.cover,
              );
            } else {
              imageWidget = const Text('No image provided.');
            }

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: imageWidget,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_specialistComments[index].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: Text(
                            'Specialist Comment: ${_specialistComments[index]}',
                            style: const TextStyle(color: Colors.black87),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (_commentAdded[index]) const SizedBox(height: 40),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Tracking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: primaryOrange,
              ),
            ),
            const SizedBox(height: 16),
            _buildLabel('Date:'),
            Text(
              job['created_at'] != null
                  ? DateFormat.yMMMd().format(DateTime.parse(job['created_at']))
                  : 'No Date',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildLabel('Location:'),
            Text(job['location'] ?? 'No Location'),
            const SizedBox(height: 16),
            _buildLabel('Description:'),
            Text(job['description'] ?? 'No Description'),
            const SizedBox(height: 20),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            const SizedBox(height: 20),
            if (_originalImages.isNotEmpty) _buildImageGallery(),
            const SizedBox(height: 24),
            const Divider(),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly),
            const SizedBox(height: 24),
            Center(
              child: _buildActionButton(
                icon: Icons.chat,
                label: 'Chat',
                color: primaryOrange,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const Chat()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
