import 'package:flutter/material.dart';
import '/widgets/custom_text_field.dart';
import '/pages/sign_up.dart';
import '../pages/user_pages/main_page.dart';
import '../pages/specialist_pages/main_page.dart';
import 'dart:convert'; // For encoding the data
import 'package:http/http.dart' as http; // For making HTTP requests
import '../constants.dart'; // To access baseUrl
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Signing in...')));

      Map<String, String> loginData = {
        'email': _emailController.text,
        'password': _passwordController.text,
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(loginData),
        );

        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          String token = responseData['token'];
          String role = responseData['role'];

          final storage = FlutterSecureStorage();
          await storage.write(key: 'auth_token', value: token);
          await storage.write(key: 'user_role', value: role);

          // Debug: confirm it was saved
          String? savedToken = await storage.read(key: 'auth_token');
          print('Token read right after write: $savedToken');

          Future.delayed(const Duration(seconds: 1), () {
            if (role == 'user') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainPage()),
              );
            } else if (role == 'specialist') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SpecialistMainPage(),
                ),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Unknown role')));
            }
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      } catch (e) {
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
          // Slogan
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
          // Form
          Form(
            key: _formKey,
            child: Column(
              children: [
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  textFieldHeight: 60.0,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your email'
                              : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                  textFieldHeight: 60.0,
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'Please enter your password'
                              : null,
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
                    child: Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Small text with Sign Up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUp(),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
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
