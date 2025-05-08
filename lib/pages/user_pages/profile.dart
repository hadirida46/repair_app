import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_appbar.dart';
import '../../pages/splash_screen.dart'; 
import '../../constants.dart'; 
import 'package:image/image.dart' as img;

const Color primaryOrange = Color(0xFFFF9800);

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // --- State Variables ---
  XFile? _image;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double? _latitude;
  double? _longitude;
  String? _profileImageUrl; // To store the URL from the backend
  final _storage = const FlutterSecureStorage(); // Secure storage for token
  String? _token; // Store the auth token
  bool _isLoading =
      false; // Track loading state for showing progress indicators

  // --- API Constants ---
  //Moved to constants.dart
  //final String _baseUrl =
  //    'http://your_laravel_api_url/api'; // Replace with your API base URL

  // --- Helper Methods ---

  // Show a red snackbar for error messages
  void _showRedSnackBar(String message) {
    if (!mounted) return; // Check if the widget is still in the tree
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

  // Show a green snackbar for success messages
  void _showGreenSnackBar(String message) {
    if (!mounted) return; // Check if the widget is still in the tree
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

  // Validate password (basic validation)
  bool _validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    return password.isNotEmpty && hasMinLength && hasUppercase && hasNumber;
  }

  // --- API Interaction Methods ---

  // Get the authentication token from secure storage
  Future<void> _getToken() async {
    try {
      _token = await _storage.read(key: 'auth_token');
      if (_token == null) {
        // Handle the case where the token is not available (e.g., redirect to login)
        _showRedSnackBar(
          'You are not logged in. Please log in to view your profile.',
        );
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => SplashScreen(),
          ), // Or your login page
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

  // Fetch user profile data from the API
  Future<void> _fetchUserProfile() async {
    if (_token == null) {
      await _getToken(); // Ensure we have the token
      if (_token == null) return; // Important:  Exit if token is still null
    }
    setState(() {
      _isLoading = true;
    }); // Start loading
    final url = Uri.parse(
      '$baseUrl/profile',
    ); // Use the baseUrl from constants.dart
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token', // Use the stored token
          'Accept': 'application/json', // Important for Laravel API
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body)['data'];
        setState(() {
          _firstNameController.text = data['first_name'] ?? '';
          _lastNameController.text = data['last_name'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
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
        _showRedSnackBar(
          'Failed to load profile: ${response.statusCode}',
        ); // Show error
        debugPrint('Failed to fetch profile: ${response.body}');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error'); // Show error
      debugPrint('Error fetching profile: $error');
    } finally {
      if (mounted) {
        //check
        setState(() {
          _isLoading = false; // Stop loading regardless of success or failure
        });
      }
    }
  }

  // Update user profile data via the API
  Future<void> _updateUserProfile() async {
    if (_token == null) {
      await _getToken();
      if (_token == null) return; // Exit if no token
    }
    if (!_formKey.currentState!.validate()) {
      return; // Stop if the form is not valid
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
            // Resize the image (optional)
            final resizedImage = img.copyResize(
              image,
              width: 800,
            ); // Adjust width as needed

            // Compress the image
            final compressedImageBytes = img.encodeJpg(
              resizedImage,
              quality: 70,
            ); 

            final compressedFile = http.MultipartFile.fromBytes(
              'profile_image',
              compressedImageBytes,
              filename:
                  'profile_image.jpg', 
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

      final streamedResponse = await request.send(); // Use send()
      final response = await http.Response.fromStream(
        streamedResponse,
      ); //convert

      final responseBody = response.body; //get body

      if (response.statusCode == 200) {
        _showGreenSnackBar('Profile updated successfully!');
        _fetchUserProfile(); //re-fetch
      } else {
        _showRedSnackBar('Failed to update profile: ${response.statusCode}');
        debugPrint('Failed to update profile: $responseBody');
      }
    } catch (error) {
      _showRedSnackBar('Error: $error');
      debugPrint('Error updating profile: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Log the user out via the API
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
        // Clear the token from secure storage
        await _storage.delete(key: 'auth_token');
        _showGreenSnackBar('Logged out successfully.');
        // Redirect to the splash screen (or login)
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

  // Delete the user's account via the API
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

  // --- Dialog Methods ---

  // Show change password dialog
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

                  // In a real app, you'd send this data to your backend to change the password
                  //  and handle the response (success/failure).
                  Navigator.pop(ctx); // Close the dialog
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

  // Show delete account confirmation dialog
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
                  _deleteAccount(); // Call the delete account API function
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  // --- Lifecycle Methods ---
  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Load user data when the widget is initialized
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  // --- UI ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
            _isLoading // Show loading indicator
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                  slivers: [
                    const CustomAppBar(title: 'Profile'),
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Form(
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
                                        //pick image and update
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
                                const SizedBox(height: 24),
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
                                  textFieldConfiguration: TextFieldConfiguration(
                                    controller: _locationController,
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      labelStyle: const TextStyle(
                                        color: Colors.orange,
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.location_on,
                                        color: Colors.orange,
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.orange,
                                        ),
                                      ),
                                      border:
                                          OutlineInputBorder(), // Added default border
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
                                            'No Name Found', // Add null check
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
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: _updateUserProfile,
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
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
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
                        ]),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
