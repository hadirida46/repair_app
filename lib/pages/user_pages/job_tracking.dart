import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import '../chat.dart';
import '../../constants.dart';

class JobTrackingPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobTrackingPage({super.key, required this.job});

  @override
  State<JobTrackingPage> createState() => _JobTrackingState();
}

class _JobTrackingState extends State<JobTrackingPage> {
  List<dynamic> _existingProgress = [];

  final List<dynamic> _originalImages = [];
  final List<File?> _compressedImages = [];
  final List<TextEditingController> _commentControllers = [];
  final List<String> _specialistComments = [];
  final List<bool> _commentAdded = [];

  final ImagePicker _picker = ImagePicker();
  static const Color primaryOrange = Color(0xFFFFA726);

  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    _syncCommentAndSpecialistLists();
    _loadExistingProgress();
  }

  @override
  void didUpdateWidget(covariant JobTrackingPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCommentAndSpecialistLists();
  }

  @override
  void dispose() {
    for (final controller in _commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _syncCommentAndSpecialistLists() {
    while (_commentControllers.length < _originalImages.length) {
      _commentControllers.add(TextEditingController());
      _specialistComments.add('');
      _commentAdded.add(false);
      _compressedImages.add(null);
    }
    while (_commentControllers.length > _originalImages.length) {
      _commentControllers.last.dispose();
      _commentControllers.removeLast();
      _specialistComments.removeLast();
      _commentAdded.removeLast();
      _compressedImages.removeLast();
    }
  }

  Future<void> _loadExistingProgress() async {
    final progressData = await _fetchProgressUpdates();
    setState(() {
      _existingProgress = progressData;
    });

    _originalImages.clear();
    _compressedImages.clear();
    _commentControllers.clear();
    _specialistComments.clear();
    _commentAdded.clear();

    for (var item in _existingProgress) {
      if (item['image_url'] != null) {
        _originalImages.add(item['image_url']);
        _compressedImages.add(null);
        _commentControllers.add(
          TextEditingController(text: item['user_comment']),
        );
        _specialistComments.add(item['specialist_comment'] ?? '');
        _commentAdded.add(
          (item['user_comment']?.isNotEmpty ?? false) ||
              (item['specialist_comment']?.isNotEmpty ?? false),
        );
      }
    }
    _syncCommentAndSpecialistLists();
  }

  Future<List<dynamic>> _fetchProgressUpdates() async {
    final reportId = widget.job['id'];
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      _showErrorSnackBar('User is not authenticated');
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
          print('Invalid response format: $responseData');
        }
      } else {
        print('Failed to fetch progress updates: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching progress: $e');
    }

    _showErrorSnackBar('Failed to load progress updates.');
    return [];
  }

  Future<void> _uploadProgress(int index) async {
    final file = _compressedImages[index] ?? _originalImages[index];
    final comment = _commentControllers[index].text;
    final reportId = widget.job['id'];

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      _showErrorSnackBar('User is not authenticated');
      return;
    }

    final uri = Uri.parse('$baseUrl/reports/$reportId/progress');

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['specialist_comment'] = comment
          ..headers['Authorization'] = 'Bearer $token';

    final mimeType = lookupMimeType(file.path);
    final multipartFile = await http.MultipartFile.fromPath(
      'image',
      file.path,
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
      filename: path.basename(file.path),
    );

    request.files.add(multipartFile);

    try {
      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Upload successful');
        setState(() {
          _specialistComments[index] = comment;
          _commentControllers[index].clear();
          _commentAdded[index] = true;
        });
        _loadExistingProgress();
      } else {
        print('Upload failed: ${response.statusCode}');
        _showErrorSnackBar('Failed to upload job progress');
      }
    } catch (e) {
      print('Upload error: $e');
      _showErrorSnackBar('Failed to upload job progress');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPickingImage) return;
    _isPickingImage = true;

    final pickedFile = await _picker.pickImage(source: source);
    _isPickingImage = false;

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final img.Image? originalImage = img.decodeImage(
        await imageFile.readAsBytes(),
      );

      if (originalImage != null) {
        img.Image resizedImage = img.copyResize(originalImage, width: 800);
        List<int> compressedBytes = img.encodeJpg(resizedImage, quality: 70);

        final Directory tempDir = await getTemporaryDirectory();
        final File compressedFile =
            await File(
              '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg',
            ).create();
        await compressedFile.writeAsBytes(compressedBytes);

        setState(() {
          _originalImages.add(imageFile);
          _compressedImages.add(compressedFile);
          _commentControllers.add(TextEditingController());
          _specialistComments.add('');
          _commentAdded.add(false);
        });
      } else {
        _showErrorSnackBar('Failed to decode the image.');
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _originalImages.removeAt(index);
      _compressedImages.removeAt(index);
      _commentControllers.removeAt(index);
      _specialistComments.removeAt(index);
      _commentAdded.removeAt(index);
    });
  }

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
        backgroundColor: Colors.red,
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
      return const Center(child: Text('No progress updates yet.'));
    }

    return Wrap(
      spacing: 12,
      runSpacing: 20,
      children:
          _originalImages.asMap().entries.map((entry) {
            final index = entry.key;
            final image = entry.value;

            Widget imageWidget;
            if (image is String) {
              imageWidget = Image.network(
                image,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => const Icon(Icons.error),
              );
            } else if (image is File) {
              imageWidget = Image.file(
                image,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              );
            } else {
              imageWidget = const Text('Invalid Image Type');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: imageWidget,
                      ),
                    ),
                    if (image is File)
                      Positioned(
                        right: -10,
                        top: -10,
                        child: IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: () => _removeImage(index),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_specialistComments[index].isNotEmpty)
                  Text(
                    ' Comment: ${_specialistComments[index]}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (!_commentAdded[index])
                      Expanded(
                        child: TextField(
                          controller: _commentControllers[index],
                          decoration: const InputDecoration(
                            labelText: 'Add your comment',
                            labelStyle: TextStyle(color: primaryOrange),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: primaryOrange),
                            ),
                          ),
                        ),
                      ),
                    if (!_commentAdded[index]) const SizedBox(width: 8),
                    if (!_commentAdded[index])
                      ElevatedButton(
                        onPressed: () => _uploadProgress(index),
                        child: const Text('Send'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    if (_commentAdded[index]) const SizedBox(width: 80),
                  ],
                ),
              ],
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
        padding: const EdgeInsets.all(16),
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
            _buildImageGallery(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(ImageSource.gallery),
        backgroundColor: primaryOrange,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}
