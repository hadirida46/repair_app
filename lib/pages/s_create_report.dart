import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../widgets/custom_appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/multiline_text_field.dart';
import '../widgets/report_status.dart';
import 'specialist_list.dart';

const primaryOrange = Color(0xFFFF9800);
const deleteIconColor = Color(0xFFB71C1C);

class SCreateReport extends StatefulWidget {
  const SCreateReport({super.key});

  @override
  State<SCreateReport> createState() => _SCreateReportState();
}

class _SCreateReportState extends State<SCreateReport>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final String _defaultLocation = "Beirut, Lebanon";
  bool _useDefaultLocation = false;
  List<File> _selectedImages = [];

  final List<Map<String, String>> _reports = [
    {
      'title': 'Broken Window',
      'date': '2024-07-20',
      'status': 'Waiting For Confirmation',
      'description': 'A window in the living room is broken.',
    },
    {
      'title': 'Leaking Sink',
      'date': '2024-07-21',
      'status': 'Accepted',
      'description': 'The kitchen sink is leaking water.',
    },
  ];

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

  void _submitReport() {
    if (_formKey.currentState!.validate() && _selectedImages.isNotEmpty) {
      // Submit logic here
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SpecialistList()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and add an image.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            const CustomAppBar(title: 'Reports'),
            SliverToBoxAdapter(
              child: TabBar(
                labelColor: primaryOrange,
                unselectedLabelColor: Colors.black,
                tabs: const [
                  Tab(text: "Create Report"),
                  Tab(text: "My Reports"),
                ],
              ),
            ),
            SliverFillRemaining(
              child: TabBarView(
                children: [
                  // CREATE REPORT TAB
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          CustomTextField(
                            controller: _titleController,
                            label: 'Title',
                            icon: Icons.title,
                            validator:
                                (value) =>
                                    value!.isEmpty
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
                                    value!.isEmpty
                                        ? 'Please enter a description'
                                        : null,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Use Default Location'),
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
                                    value!.isEmpty
                                        ? 'Please enter a location'
                                        : null,
                            enabled: !_useDefaultLocation,
                          ),
                          const SizedBox(height: 20),
                          if (_selectedImages.isNotEmpty)
                            Column(
                              children: List.generate(_selectedImages.length, (
                                index,
                              ) {
                                return Stack(
                                  alignment: Alignment.topRight,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        _selectedImages[index],
                                        height: 180,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.remove_circle,
                                        color: deleteIconColor,
                                      ),
                                      onPressed: () => _removeImage(index),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => _pickImage(ImageSource.camera),
                                  icon: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Take Photo",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed:
                                      () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Upload Photo",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _submitReport,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo[900],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              'Search for Specialist',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // MY REPORTS TAB
                  _reports.isEmpty
                      ? const Center(
                        child: Text(
                          'No reports yet',
                          style: TextStyle(color: primaryOrange),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _reports.length,
                        itemBuilder: (context, index) {
                          final report = _reports[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  report['title']!,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: primaryOrange,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text('Date: ${report['date']}'),
                                Row(
                                  children: [
                                    const Text('Status: '),
                                    ReportStatus(status: report['status']!),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(report['description']!),
                              ],
                            ),
                          );
                        },
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
