import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; 

class UserProfile extends StatelessWidget {
  const UserProfile({Key? key}) : super(key: key);

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
                  Navigator.pop(ctx);
                  // Perform delete logic here
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.indigo[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                    'assets/profile_pic.png',
                  ), // Replace with actual image logic
                ),
                Positioned(
                  child: IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.orange),
                    onPressed: () {
                      // TODO: Open image picker
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Hadi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'hadi@example.com',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Change Full Name
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Change Full Name'),
              onTap: () {
                // TODO: Navigate or open dialog to change name
              },
            ),

            // Change Email
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text('Change Email'),
              onTap: () {
                // TODO: Navigate or open dialog to change email
              },
            ),

            // Change Password
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              onTap: () {
                // TODO: Navigate to change password
              },
            ),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                // TODO: Implement logout
              },
            ),

            const Divider(),

            // Delete Account
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Delete Account',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () => _showDeleteDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}
