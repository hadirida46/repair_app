import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../chat.dart';

class JobProgressPage extends StatefulWidget {
  final Map<String, String> job;

  const JobProgressPage({super.key, required this.job});

  @override
  State<JobProgressPage> createState() => _JobProgressPageState();
}

class _JobProgressPageState extends State<JobProgressPage> {
  static const Color primaryOrange = Color(0xFFFFA726);
  final ImagePicker _picker = ImagePicker();

  final List<File> _images = [];
  final List<TextEditingController> _commentControllers = [];
  final List<String> _specialistComments = [];
  final List<bool> _commentAdded = [];

  @override
  void initState() {
    super.initState();
    _syncCommentAndSpecialistLists();
  }

  @override
  void didUpdateWidget(covariant JobProgressPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncCommentAndSpecialistLists();
  }

  void _syncCommentAndSpecialistLists() {
    while (_commentControllers.length < _images.length) {
      _commentControllers.add(TextEditingController());
      _specialistComments.add('');
      _commentAdded.add(false);
    }
    while (_commentControllers.length > _images.length) {
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
        _commentControllers.add(TextEditingController());
        _specialistComments.add('');
        _commentAdded.add(false);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      _commentControllers.removeAt(index);
      _specialistComments.removeAt(index);
      _commentAdded.removeAt(index);
    });
  }

  void _sendComment(int index) {
    final userComment = _commentControllers[index].text;
    print('User comment for image ${index + 1}: $userComment');

    setState(() {
      _specialistComments[index] = userComment;
      _commentControllers[index].clear();
      _commentAdded[index] = true;
    });
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
    return Wrap(
      spacing: 12,
      runSpacing: 20,
      children:
          _images.asMap().entries.map((entry) {
            final index = entry.key;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        entry.value,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Specialist Comment: ${_specialistComments[index]}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
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
                        onPressed: () => _sendComment(index),
                        child: const Text('Send'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    if (_commentAdded[index]) const Expanded(child: SizedBox()),
                    if (_commentAdded[index]) const SizedBox(width: 8),
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
            Text(job['date'] ?? 'No Date'),
            const SizedBox(height: 8),
            _buildLabel('Location:'),
            Text(job['location'] ?? 'No Location'),
            const SizedBox(height: 8),
            _buildLabel('Reported By:'),
            Text(job['Reported_by'] ?? 'No Specialist Assigned'),
            const SizedBox(height: 16),
            _buildLabel('Description:'),
            Text(job['description'] ?? 'No Description'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.camera_alt,
                    label: 'Take Photo',
                    color: primaryOrange,
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.upload_file,
                    label: 'Upload Photo',
                    color: primaryOrange,
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (_images.isNotEmpty) _buildImageGallery(),
            const SizedBox(height: 24),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.check,
                  label: 'Complete',
                  color: Colors.green,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job marked as completed!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
                _buildActionButton(
                  icon: Icons.stop_circle_outlined,
                  label: 'Stop Job',
                  color: Colors.red,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Job has been stopped by specialist.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: _buildActionButton(
                icon: Icons.save,
                label: 'Save',
                color: primaryOrange,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Job progress saved!'),
                      backgroundColor: primaryOrange,
                    ),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
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
