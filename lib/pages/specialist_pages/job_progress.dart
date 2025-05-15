import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class JobProgressPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const JobProgressPage({super.key, required this.job});

  @override
  State<JobProgressPage> createState() => _JobProgressPageState();
}

class _JobProgressPageState extends State<JobProgressPage> {
  List<dynamic> _existingProgress = [];
  @override
  void initState() {
    super.initState();
    _syncCommentAndSpecialistLists();
    _loadExistingProgress();
  }

  Future<void> _updateJobStatus(String status) async {
    final reportId = widget.job['id'];
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      return _showErrorSnackBar('User is not authenticated.');
    }

    final uri = Uri.parse('$baseUrl/reports/$reportId/status');

    try {
      final response = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Job marked as $status!'),
            backgroundColor: status == 'completed' ? Colors.green : Colors.red,
          ),
        );
        Navigator.pop(context);
      } else {
        _showErrorSnackBar('Failed to update job status.');
      }
    } catch (error) {
      _showErrorSnackBar('Failed to update job status: $error');
    }
  }

  Future<void> _loadExistingProgress() async {
    final progressData = await _fetchProgressUpdates();
    setState(() {
      _existingProgress = progressData;
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
            item['user_comment']?.isNotEmpty == true ||
                item['specialist_comment']?.isNotEmpty == true,
          );
        }
      }
    });
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

  Future<void> _uploadProgress(int index) async {
    final file = _compressedImages[index] ?? _originalImages[index];
    final comment = _commentControllers[index].text;
    final reportId = widget.job['id'];
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    if (token == null) return _showErrorSnackBar('User is not authenticated.');

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

    final response = await request.send();
    if (response.statusCode == 200 || response.statusCode == 201) {
      _commentControllers[index].clear();
      _commentAdded[index] = true;
      _loadExistingProgress();
    } else {
      _showErrorSnackBar('Upload failed.');
    }
  }

  static const Color primaryOrange = Color(0xFFFFA726);
  final ImagePicker _picker = ImagePicker();

  final List<dynamic> _originalImages = [];
  final List<File?> _compressedImages = [];
  final List<TextEditingController> _commentControllers = [];
  final List<String> _specialistComments = [];
  final List<bool> _commentAdded = [];

  @override
  void didUpdateWidget(covariant JobProgressPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCommentAndSpecialistLists();
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

  @override
  void dispose() {
    for (final controller in _commentControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isPickingImage = false;
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
        final resizedImage = img.copyResize(originalImage, width: 800);
        final compressedBytes = img.encodeJpg(resizedImage, quality: 70);
        final tempDir = await getTemporaryDirectory();
        final compressedFile =
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
        _showErrorSnackBar('Failed to process image.');
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
            if (image is String) {
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
              imageWidget = const Text('Invalid Image');
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
                        if (image is File)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.white70,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeImage(index),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_specialistComments[index].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Specialist Comment: ${_specialistComments[index]}',
                          style: const TextStyle(color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (!_commentAdded[index])
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentControllers[index],
                                decoration: const InputDecoration(
                                  labelText: 'Add your comment',
                                  border: OutlineInputBorder(),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: primaryOrange,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _uploadProgress(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text('Send'),
                            ),
                          ],
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
          'Job Progress',
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
            const SizedBox(height: 8),
            _buildLabel('Reported By:'),
            Text(
              '${job['reported_by']?['first_name'] ?? ''} ${job['reported_by']?['last_name'] ?? ''}'
                      .trim() ??
                  'Unknown',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              job['reported_by']?['email'] ?? 'No Email',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildLabel('Description:'),
            Text(job['description'] ?? 'No Description'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    label: const Text(
                      'Take Photo',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.upload_file, color: Colors.white),
                    label: const Text(
                      'Upload Photo',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_originalImages.isNotEmpty) _buildImageGallery(),
            const SizedBox(height: 24),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.check,
                      label: 'Complete',
                      color: Colors.green,
                      onPressed: () {
                        _updateJobStatus('completed');
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildActionButton(
                      icon: Icons.stop_circle_outlined,
                      label: 'Stop Job',
                      color: Colors.red,
                      onPressed: () {
                        _updateJobStatus('escalated');
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
