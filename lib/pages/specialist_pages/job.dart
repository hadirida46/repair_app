import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../chat.dart';
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class JobPage extends StatelessWidget {
  final Map<String, dynamic> job;

  const JobPage({super.key, required this.job});
  static const Color primaryOrange = Color(0xFFFFA726);

  Future<void> updateJobStatus(
    BuildContext context,
    int jobId,
    String status,
  ) async {
    final String url = '$baseUrl/reports/$jobId/status';
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final Map<String, String> body = {'status': status};

    try {
      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Status updated successfully!')));
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${errorData['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('An error occurred')));
    }
  }

  Future<String> _getAuthToken() async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: 'auth_token') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final String name =
        '${job['reported_by']?['first_name'] ?? ''} ${job['reported_by']?['last_name'] ?? ''}'
            .trim();
    final String email = job['reported_by']?['email'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
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
                  Text(
                    job['created_at'] != null
                        ? DateFormat.yMMMd().format(
                          DateTime.parse(job['created_at']),
                        )
                        : 'No Date',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildLabel('Location:'),
                  Text(
                    job['location'] ?? 'No Location',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  _buildLabel('Reported By:'),
                  Text(
                    '${job['reported_by']?['first_name'] ?? ''} ${job['reported_by']?['last_name'] ?? ''}'
                            .trim() ??
                        'Unknown',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    job['reported_by']?['email'] ?? 'No Email',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  _buildLabel('Description:'),
                  Text(
                    job['description'] ?? 'No Description',
                    style: const TextStyle(fontSize: 16),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 20),

                  // Display all images
                  if (job['images'] != null && job['images'].isNotEmpty)
                    ...job['images'].map<Widget>((imageUrl) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Text(
                              'Image failed to load.',
                              style: TextStyle(color: Colors.red),
                            );
                          },
                        ),
                      );
                    }).toList(),

                  const SizedBox(height: 12),
                  // Center(
                  //   child: _buildActionButton(
                  //     icon: Icons.chat,
                  //     label: 'Chat',
                  //     color: primaryOrange,
                  //     onPressed: () {
                  //       Navigator.push(
                  //         context,
                  //         MaterialPageRoute(builder: (_) => const Chat()),
                  //       );
                  //     },
                  //   ),
                  // ),
                  const SizedBox(height: 12),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          updateJobStatus(context, job['id'], 'in progress');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check, color: Colors.white),
                        label: const Text(
                          'Accept',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          updateJobStatus(context, job['id'], 'rejected');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text(
                          'Reject',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 24,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
}
