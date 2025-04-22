import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multiline_text_field.dart';

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
      debugPrint('Selected image path: ${pickedFile.path}');
    }
  }

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add or take a photo before submitting.'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            margin: EdgeInsets.all(16),
          ),
        );
        return;
      }

      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final location = _locationController.text.trim();

      debugPrint('Title: $title');
      debugPrint('Description: $description');
      debugPrint('Location: $location');
      debugPrint('Number of images selected: ${_selectedImages.length}');
      // Send this data to backend here
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
    debugPrint('Image at index $index removed');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: <Widget>[
          const CustomAppBar(title: 'Create Report'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
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
                        // Replace the TextField for description with CustomMultilineTextField
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
                                  if (value) {
                                    _locationController.text = _defaultLocation;
                                  } else {
                                    _locationController.clear();
                                  }
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
                          enabled: !_useDefaultLocation,//here
                        ),
                        const SizedBox(height: 30),
                        if (_selectedImages.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: List.generate(_selectedImages.length, (
                              index,
                            ) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Stack(
                                  clipBehavior: Clip.none,
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _pickImage(ImageSource.camera),
                                    icon: const Icon(
                                      Icons.camera_alt,
                                      size: 20,
                                    ),
                                    label: const Text('Take Photo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryOrange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  height: 40,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed:
                                        () => _pickImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo, size: 20),
                                    label: const Text('Upload Photo'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryOrange,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: ElevatedButton(
                            onPressed: _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[900],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              '\t\tSearch for Specialist\t\t',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
