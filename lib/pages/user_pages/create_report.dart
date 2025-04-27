import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/multiline_text_field.dart';
import 'specialist_list.dart';

const primaryOrange = Color(0xFFFF9800);
const deleteIconColor = Color(0xFFB71C1C);

class CreateReport extends StatefulWidget {
  const CreateReport({super.key});

  @override
  State<CreateReport> createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  bool _useDefaultLocation = false;
  String _defaultLocation = "Beirut, Lebanon";
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<File> _selectedImages = [];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
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
        backgroundColor: deleteIconColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please complete all required fields.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showErrorSnackBar('Please add or take a photo before proceeding.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SpecialistList()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: 'Create Report'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CustomTextField(
                      controller: _titleController,
                      label: 'Title',
                      icon: Icons.title,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter a title'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    CustomMultilineTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      icon: Icons.description,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter a description'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Use Default Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Switch(
                          value: _useDefaultLocation,
                          activeColor: primaryOrange,
                          onChanged: (value) {
                            setState(() {
                              _useDefaultLocation = value;
                              _locationController.text =
                                  value ? _defaultLocation : '';
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      controller: _locationController,
                      label: 'Location',
                      icon: Icons.location_on,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Please enter a location'
                                  : null,
                      enabled: !_useDefaultLocation,
                    ),
                    const SizedBox(height: 30),
                    if (_selectedImages.isNotEmpty)
                      Column(
                        children: List.generate(_selectedImages.length, (
                          index,
                        ) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _selectedImages[index],
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: deleteIconColor,
                                    ),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.camera),
                              icon: const Icon(Icons.camera_alt, size: 20),
                              label: const Text('Take Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _pickImage(ImageSource.gallery),
                              icon: const Icon(Icons.photo, size: 20),
                              label: const Text('Upload Photo'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '\t\tSearch for Specialist\t\t',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
