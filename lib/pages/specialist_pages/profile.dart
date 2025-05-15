import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../widgets/custom_text_field.dart';
import '../../widgets/multiline_text_field.dart';
import '/widgets/custom_appbar.dart';
import '/pages/splash_screen.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const Color primaryOrange = Color(0xFFFF9800);

class SpecialistProfile extends StatefulWidget {
  const SpecialistProfile({Key? key}) : super(key: key);

  @override
  State<SpecialistProfile> createState() => _SpecialistProfileState();
}

class _SpecialistProfileState extends State<SpecialistProfile> {
  XFile? _image;
  String? _profileImageUrl; // To store the URL from the backend
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  String? _selectedSpecialization;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  final _storage = const FlutterSecureStorage();
  String? _token;

  final List<String> _specializations = [
    'contractor',
    'electrician',
    'plumber',
    'handyman',
  ];

  List<dynamic> _specialistFeedbacks = [];

  void _showRedSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showGreenSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  bool _validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    return password.isNotEmpty && hasMinLength && hasUppercase && hasNumber;
  }

  Future<void> _fetchSpecialistFeedback() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return;
    }

    final url = Uri.parse('$baseUrl/feedback/specialist');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _specialistFeedbacks = data['feedbacks'];
        });
      } else if (response.statusCode == 404) {
        setState(() {
          _specialistFeedbacks = [];
          _showRedSnackBar(json.decode(response.body)['message']);
        });
      } else {
        _showRedSnackBar('Failed to load feedback: ${response.statusCode}');
        debugPrint('Failed to fetch feedback: ${response.body}');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error fetching feedback: $error');
    }
  }

  Future<void> _getToken() async {
    try {
      _token = await _storage.read(key: 'auth_token');
      if (_token == null) {
        _showRedSnackBar(
          'You are not logged in. Please log in to view your profile.',
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      _showRedSnackBar('Error accessing secure storage: $e');
      debugPrint('Error accessing secure storage: $e');
      setState(() {
        _isLoading = false;
      });
      return;
    }
  }

  Future<void> _fetchSpecialistProfile() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return;
    }
    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('$baseUrl/profile');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body)['data'];
        debugPrint('Backend Specialization Value: ${data['specialization']}');
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _selectedSpecialization = data['specialization'];
          _latitude =
              data['latitude'] != null
                  ? double.tryParse(data['latitude'].toString())
                  : null;
          _longitude =
              data['longitude'] != null
                  ? double.tryParse(data['longitude'].toString())
                  : null;
          _profileImageUrl = data['profile_image'];
        });
      } else {
        _showRedSnackBar('Failed to load profile: ${response.statusCode}');
        debugPrint('Failed to fetch specialist profile: ${response.body}');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error fetching specialist profile: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateSpecialistProfile() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    final url = Uri.parse('$baseUrl/profile/update');
    try {
      final request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $_token';
      request.headers['Accept'] = 'application/json';

      request.fields['first_name'] = _firstNameController.text.trim();
      request.fields['last_name'] = _lastNameController.text.trim();
      request.fields['email'] = _emailController.text.trim();
      request.fields['location'] = _locationController.text.trim();
      request.fields['bio'] = _bioController.text.trim();
      request.fields['specialization'] = _selectedSpecialization!;
      if (_latitude != null) {
        request.fields['latitude'] = _latitude.toString();
      }
      if (_longitude != null) {
        request.fields['longitude'] = _longitude.toString();
      }

      if (_image != null) {
        try {
          final file = File(_image!.path);
          final bytes = await file.readAsBytes();
          final image = img.decodeImage(bytes);
          if (image != null) {
            final resizedImage = img.copyResize(image, width: 800);
            final compressedImageBytes = img.encodeJpg(
              resizedImage,
              quality: 70,
            );
            final compressedFile = http.MultipartFile.fromBytes(
              'profile_image',
              compressedImageBytes,
              filename: 'profile_image.jpg',
            );
            request.files.add(compressedFile);
          } else {
            _showRedSnackBar('Error decoding image.');
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } catch (e) {
          _showRedSnackBar('Error processing image: $e');
          debugPrint('Error processing image: $e');
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseBody = response.body;

      if (response.statusCode == 200) {
        _showGreenSnackBar('Profile updated successfully!');
        _fetchSpecialistProfile();
      } else {
        _showRedSnackBar('Failed to update profile: ${response.statusCode}');
        debugPrint('Failed to update specialist profile: $responseBody');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error updating specialist profile: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return;
    }
    final url = Uri.parse('$baseUrl/logout');
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _storage.delete(key: 'auth_token');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
        );
      } else {
        _showRedSnackBar('Failed to logout: ${response.statusCode}');
        debugPrint('Logout failed: ${response.body}');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error during logout: $error');
    }
  }

  Future<void> _deleteAccount() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return;
    }
    final url = Uri.parse('$baseUrl/profile/delete');
    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await _storage.delete(key: 'auth_token');
        _showGreenSnackBar('Account deleted successfully.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => SplashScreen()),
          (route) => false,
        );
      } else {
        _showRedSnackBar('Failed to delete account: ${response.statusCode}');
        debugPrint('Failed account deletion: ${response.body}');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error deleting account: $error');
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  final current = currentPasswordController.text.trim();
                  final newPass = newPasswordController.text.trim();
                  final confirmPass = confirmPasswordController.text.trim();

                  if (current.isEmpty ||
                      newPass.isEmpty ||
                      confirmPass.isEmpty) {
                    _showRedSnackBar('All password fields must be filled.');
                    return;
                  }

                  if (!_validatePassword(newPass)) {
                    _showRedSnackBar(
                      'Password must be at least 8 characters,\ninclude a number and an uppercase letter.',
                    );
                    return;
                  }

                  if (newPass != confirmPass) {
                    _showRedSnackBar(
                      'New password and confirmation do not match.',
                    );
                    return;
                  }

                  Navigator.pop(ctx);
                  debugPrint('Password change requested: $current → $newPass');
                  _showGreenSnackBar(
                    'Password change functionality not implemented in this example.',
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  _deleteAccount();
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSpecialistProfile();
    _fetchSpecialistFeedback();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    const CustomAppBar(title: 'Profile'),
                    SliverPadding(
                      padding: const EdgeInsets.all(20.0),
                      sliver: SliverFillRemaining(
                        hasScrollBody: true,
                        child: SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    CircleAvatar(
                                      radius: 60,
                                      backgroundImage:
                                          _profileImageUrl != null
                                              ? NetworkImage(
                                                '$_profileImageUrl',
                                              )
                                              : _image != null
                                              ? FileImage(File(_image!.path))
                                              : const AssetImage(
                                                    'assets/profile_pic.png',
                                                  )
                                                  as ImageProvider,
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.add_circle,
                                        color: primaryOrange,
                                      ),
                                      onPressed: () async {
                                        final pickedImage = await ImagePicker()
                                            .pickImage(
                                              source: ImageSource.gallery,
                                            );
                                        if (pickedImage != null) {
                                          setState(() {
                                            _image = pickedImage;
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _firstNameController,
                                        label: 'First Name',
                                        icon: Icons.person,
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Enter your first name'
                                                    : null,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: CustomTextField(
                                        controller: _lastNameController,
                                        label: 'Last Name',
                                        icon: Icons.person_outline,
                                        validator:
                                            (value) =>
                                                value == null || value.isEmpty
                                                    ? 'Enter your last name'
                                                    : null,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                CustomTextField(
                                  controller: _emailController,
                                  label: 'Email',
                                  icon: Icons.email,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Enter your email';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    );
                                    if (!emailRegex.hasMatch(value)) {
                                      return 'Enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TypeAheadFormField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                        controller: _locationController,
                                        decoration: InputDecoration(
                                          labelText: 'Location',
                                          labelStyle: const TextStyle(
                                            color: primaryOrange,
                                          ),
                                          prefixIcon: const Icon(
                                            Icons.location_on,
                                            color: primaryOrange,
                                          ),
                                          focusedBorder:
                                              const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: primaryOrange,
                                                ),
                                              ),
                                          enabledBorder:
                                              const OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  color: primaryOrange,
                                                ),
                                              ),
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
                                        debugPrint(
                                          'API Error: ${response.statusCode}\nResponse Body: ${response.body}',
                                        );
                                        return [];
                                      }
                                    } catch (e) {
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
                                      suggestion['lat'],
                                    );
                                    _longitude = double.tryParse(
                                      suggestion['lon'],
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
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value:
                                      _selectedSpecialization == 'null'
                                          ? null
                                          : _selectedSpecialization,
                                  decoration: const InputDecoration(
                                    labelText: 'Specialization',
                                    labelStyle: TextStyle(color: primaryOrange),
                                    prefixIcon: Icon(
                                      Icons.build,
                                      color: primaryOrange,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primaryOrange,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primaryOrange,
                                        width: 2.0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: primaryOrange,
                                      ),
                                    ),
                                  ),
                                  iconEnabledColor: primaryOrange,
                                  dropdownColor: Colors.white,
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: null,
                                      child: Text('Select Specialization'),
                                    ),
                                    ..._specializations
                                        .map(
                                          (spec) => DropdownMenuItem(
                                            value: spec,
                                            child: Text(spec),
                                          ),
                                        )
                                        .toList(),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSpecialization = value;
                                    });
                                  },
                                  validator:
                                      (value) =>
                                          value == null
                                              ? 'Please select a specialization'
                                              : null,
                                ),
                                const SizedBox(height: 16),
                                CustomMultilineTextField(
                                  controller: _bioController,
                                  label: 'Bio',
                                  icon: Icons.description,
                                  validator:
                                      (value) =>
                                          value == null || value.isEmpty
                                              ? 'Enter your bio'
                                              : null,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _updateSpecialistProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryOrange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    '\t\tSave Changes\t\t',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                const Divider(),
                                const Text(
                                  'Feedbacks',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                _specialistFeedbacks.isEmpty
                                    ? const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        'No feedback available for this specialist.',
                                      ),
                                    )
                                    : ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: _specialistFeedbacks.length,
                                      itemBuilder: (context, index) {
                                        final feedback =
                                            _specialistFeedbacks[index];
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.comment,
                                            color: Colors.orange,
                                          ),
                                          title: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              feedback['comment'] ??
                                                  'No comment',
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                const Divider(),
                                ListTile(
                                  leading: const Icon(Icons.lock),
                                  title: const Text('Change Password'),
                                  onTap:
                                      () => _showChangePasswordDialog(context),
                                ),
                                ListTile(
                                  leading: const Icon(Icons.logout),
                                  title: const Text('Logout'),
                                  onTap: _logout,
                                ),
                                ListTile(
                                  leading: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  title: const Text(
                                    'Delete Account',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onTap: () => _showDeleteDialog(context),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
