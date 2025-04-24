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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
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
      runSpacing: 12,
      children:
          _images.asMap().entries.map((entry) {
            return Stack(
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
                    onPressed: () => _removeImage(entry.key),
                  ),
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
            _buildLabel('Handled by:'),
            Text(job['handled_by'] ?? 'No Specialist Assigned'),
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
