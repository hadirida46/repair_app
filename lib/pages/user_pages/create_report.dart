import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/multiline_text_field.dart';
import 'specialist_list.dart';
import '../../constants.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

const primaryOrange = Color(0xFFFF9800);
const deleteIconColor = Color(0xFFB71C1C);

class CreateReport extends StatefulWidget {
  const CreateReport({super.key});

  @override
  State<CreateReport> createState() => _CreateReportState();
}

class _CreateReportState extends State<CreateReport> {
  bool _useDefaultLocation = false;
  String _defaultLocationText = "";
  double? _defaultLatitude;
  double? _defaultLongitude;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<File> _selectedImages = [];
  double? _latitude;
  double? _longitude;
  final _storage = const FlutterSecureStorage();
  bool _isFetchingDefaultLocation = false;
  String? _selectedSpecialization;
  final List<String> _specializations = [
    'contractor',
    'electrician',
    'plumber',
    'handyman',
  ];
  @override
  void initState() {
    super.initState();

    if (_useDefaultLocation) {
      _locationController.text = _defaultLocationText;
      _latitude = _defaultLatitude;
      _longitude = _defaultLongitude;
    }
    _loadDefaultLocation();
  }

  Future<void> _loadDefaultLocation() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/profile'),
          headers: {'Authorization': 'Bearer $token'},
        );

        debugPrint(
          'Default Location Response Status Code: ${response.statusCode}',
        );
        debugPrint('Default Location Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final userData = json.decode(response.body);
          final user = userData['data'];

          final String location = user['location'] ?? "";
          final double? latitude =
              user['latitude'] != null
                  ? double.tryParse(user['latitude'].toString())
                  : null;
          final double? longitude =
              user['longitude'] != null
                  ? double.tryParse(user['longitude'].toString())
                  : null;

          setState(() {
            _defaultLocationText = location;
            _defaultLatitude = latitude;
            _defaultLongitude = longitude;
            _isFetchingDefaultLocation = false;

            if (_useDefaultLocation && _defaultLocationText.isNotEmpty) {
              _locationController.text = _defaultLocationText;
              _latitude = _defaultLatitude;
              _longitude = _defaultLongitude;
            }
          });
        } else {
          setState(() => _isFetchingDefaultLocation = false);
          _showErrorSnackBar('Failed to load default location.');
        }
      } catch (e) {
        setState(() => _isFetchingDefaultLocation = false);
        _showErrorSnackBar('Error loading default location: $e');
      }
    } else {
      setState(() => _isFetchingDefaultLocation = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
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
          _selectedImages.add(compressedFile);
        });
      } else {
        _showErrorSnackBar('Failed to decode the image.');
      }
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      _showErrorSnackBar('Please complete all required fields.');
      return;
    }
    if (_selectedImages.isEmpty) {
      _showErrorSnackBar('Please add or take a photo before proceeding.');
      return;
    }

    final token = await _storage.read(key: 'auth_token');
    if (token == null) {
      _showErrorSnackBar(
        'Authentication token not found. Please log in again.',
      );
      return;
    }

    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/reports'));

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['title'] = _titleController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['location'] = _locationController.text;
    if (_latitude != null) {
      request.fields['latitude'] = _latitude!.toString();
    }
    if (_longitude != null) {
      request.fields['longitude'] = _longitude!.toString();
    }
    if (_selectedSpecialization != null) {
      request.fields['specialist_type'] = _selectedSpecialization!;
    } else {
      _showErrorSnackBar('Please select a specialization.');
      return; 
    }

    for (var imageFile in _selectedImages) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      String fileName = p.basename(imageFile.path);
      var multipartFile = http.MultipartFile(
        'images[]',
        stream,
        length,
        filename: fileName,
      );
      request.files.add(multipartFile);
    }

    try {
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        final responseData = json.decode(responseBody);
        _showSuccessSnackBar('Report created successfully!');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SpecialistList()),
        );
      } else {
        _showErrorSnackBar(
          'Failed to create report. ${response.statusCode}\n$responseBody',
        );
        debugPrint(
          'Failed to create report: ${response.statusCode}\n$responseBody',
        );
      }
    } catch (e) {
      _showErrorSnackBar('Error sending report: $e');
      debugPrint('Error sending report: $e');
    }
  }

  void _showRedSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
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
              child:
                  _isFetchingDefaultLocation
                      ? const Center(child: CircularProgressIndicator())
                      : Form(
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
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              value: _selectedSpecialization,
                              decoration: const InputDecoration(
                                labelText: 'Specialization',
                                labelStyle: TextStyle(color: primaryOrange),
                                prefixIcon: Icon(
                                  Icons.build,
                                  color: primaryOrange,
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryOrange),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryOrange,
                                    width: 2.0,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: primaryOrange),
                                ),
                              ),
                              iconEnabledColor: primaryOrange,
                              dropdownColor: Colors.white,
                              items:
                                  _specializations
                                      .map(
                                        (spec) => DropdownMenuItem(
                                          value: spec,
                                          child: Text(spec),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(
                                    () => _selectedSpecialization = value,
                                  );
                                }
                              },
                            ),
                            const SizedBox(height: 16),
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
                                      debugPrint(
                                        'Switch toggled, value: $value, _defaultLocationText: $_defaultLocationText',
                                      ); // ADD THIS LINE
                                      if (value &&
                                          _defaultLocationText.isNotEmpty) {
                                        debugPrint(
                                          'Setting location to: $_defaultLocationText',
                                        );
                                        _locationController.text =
                                            _defaultLocationText;
                                        _latitude = _defaultLatitude;
                                        _longitude = _defaultLongitude;
                                      } else {
                                        _locationController.text = '';
                                        _latitude = null;
                                        _longitude = null;
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TypeAheadFormField(
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _locationController,
                                decoration: const InputDecoration(
                                  labelText: 'Location',
                                  labelStyle: TextStyle(color: Colors.orange),
                                  prefixIcon: Icon(
                                    Icons.location_on,
                                    color: Colors.orange,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.orange,
                                    ),
                                  ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              suggestionsCallback: (pattern) async {
                                if (pattern.length < 2) {
                                  return [];
                                }
                                final query = '$pattern, Lebanon';
                                final url = Uri.parse(
                                  'https://nominatim.openstreetmap.org/search?format=json&q=$query',
                                );
                                try {
                                  final response = await http.get(
                                    url,
                                    headers: {
                                      'User-Agent':
                                          'repair_app/1.0 (hadirdia46.gmail.com)',
                                    },
                                  );

                                  if (response.statusCode == 200) {
                                    try {
                                      final List data = json.decode(
                                        response.body,
                                      );
                                      debugPrint('API Response: $data');
                                      return data;
                                    } catch (e) {
                                      debugPrint(
                                        'Error decoding JSON: $e\nResponse Body: ${response.body}',
                                      );
                                      return [];
                                    }
                                  } else {
                                    _showRedSnackBar(
                                      'Failed to fetch location suggestions: ${response.statusCode}',
                                    );
                                    debugPrint(
                                      'API Error: ${response.statusCode}\nResponse Body: ${response.body}',
                                    );
                                    return [];
                                  }
                                } catch (e) {
                                  _showRedSnackBar(
                                    'Error fetching location suggestions: $e',
                                  );
                                  debugPrint('Network error: $e');
                                  return [];
                                }
                              },
                              itemBuilder: (context, suggestion) {
                                debugPrint('Suggestion Item: $suggestion');
                                return ListTile(
                                  title: Text(
                                    suggestion['display_name'] ??
                                        'No Name Found',
                                  ),
                                );
                              },
                              onSuggestionSelected: (suggestion) {
                                _locationController.text =
                                    suggestion['display_name'];
                                _latitude = double.tryParse(
                                  suggestion['lat']?.toString() ?? '',
                                );
                                _longitude = double.tryParse(
                                  suggestion['lon']?.toString() ?? '',
                                );
                                debugPrint(
                                  'Selected Location: $_latitude, $_longitude',
                                );
                              },
                              validator:
                                  (value) =>
                                      value == null || value.isEmpty
                                          ? 'Enter your location'
                                          : null,
                            ),
                            const SizedBox(height: 30),
                            if (_selectedImages.isNotEmpty)
                              Column(
                                children: List.generate(
                                  _selectedImages.length,
                                  (index) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                              onPressed:
                                                  () => _removeImage(index),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Row(
                                children: [
                                  Expanded(
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
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        elevation: 4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          () => _pickImage(ImageSource.gallery),
                                      icon: const Icon(Icons.photo, size: 20),
                                      label: const Text('Upload Photo'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryOrange,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
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
                              onPressed: _submitReport,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[900],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 4,
                              ),
                              child: const Text(
                                'Submit Report',
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
