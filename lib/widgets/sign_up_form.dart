import 'package:flutter/material.dart';
import '/pages/sign_in.dart';
import '../pages/user_pages/main_page.dart';
import '../pages/specialist_pages/main_page.dart';
import '/widgets/custom_text_field.dart';
import '/widgets/user_specialist_toggle.dart';
import 'dart:convert'; // For encoding the data
import 'package:http/http.dart' as http; // For making HTTP requests
import '../constants.dart'; // To access baseUrl
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();


  String selectedRole = 'User';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    } else if (value.length < 8) {
      return 'Password must be at least 8 characters';
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    } else if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your email';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      // Show loading message or SnackBar
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signing up...')));

      // Prepare data for the API request
      Map<String, String> userData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'password_confirmation': _confirmPasswordController.text,
        'role': selectedRole == 'User' ? 'user' : 'specialist',
      };

      try {
        // Make the POST request to your Laravel API
        final response = await http.post(
          Uri.parse(
            '$baseUrl/register',
          ), // Use baseUrl for your local Laravel API
          headers: {'Content-Type': 'application/json'},
          body: json.encode(userData), // Convert map to JSON
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);
          final token = data['token'];
          final user = data['user'];

          // Store the token securely
          await _secureStorage.write(key: 'auth_token', value: token);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration successful!')),
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (user['role'] == 'specialist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpecialistMainPage(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            }
          });
        } else {
          // If the response is not OK, show an error
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      } catch (e) {
        // Handle network errors or other exceptions
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, size: 28),
              color: Colors.black,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignIn()),
                );
              },
            ),
          ),
          Text(
            "Home or office,\nwe've got your back",
            style: TextStyle(
              fontFamily: 'Lobster',
              fontSize: 30,
              color: primaryOrange,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  icon: Icons.person,
                  textFieldHeight: 60.0,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Enter your first name'
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  icon: Icons.person_outline,
                  textFieldHeight: 60.0,
                  validator:
                      (value) =>
                          (value == null || value.isEmpty)
                              ? 'Enter your last name'
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textFieldHeight: 60.0,
                  validator:
                      validateEmail, // Use the new validateEmail function
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textFieldHeight: 60.0,
                  validator: validatePassword,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  textFieldHeight: 60.0,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    } else if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                UserSpecialistToggle(
                  initialValue: selectedRole,
                  onToggle: (role) {
                    setState(() {
                      selectedRole = role;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 50,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 5,
                    ),
                    onPressed: _submit,
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignIn(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
