import 'package:flutter/material.dart';
import '../../widgets/custom_text_field.dart';

class JobTrackingPage extends StatefulWidget {
  JobTrackingPage({super.key});

  @override
  State<JobTrackingPage> createState() => _JobTrackingPageState();
}

class _JobTrackingPageState extends State<JobTrackingPage> {
  final Color primaryOrange = const Color(0xFFFF9800);

  final TextEditingController _commentController = TextEditingController();
  List<String> userComments = [];
  // Will hold the user comment after sending

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Job Tracking',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Report Info Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Title:', 'Electrical Issue'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Handled by:', 'John Doe'),
                  const SizedBox(height: 8),
                  _buildInfoRow('Start Date:', 'April 26, 2025'),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    'Description:',
                    'Power outage in living room. Power outage in living room.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Progress Updates
            _buildProgressUpdate(
              specialistUpdate: 'We replaced the damaged cables.',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: primaryOrange,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15)),
      ],
    );
  }

  Widget _buildProgressUpdate({required String specialistUpdate}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specialist Note
          Text(
            'Specialist Update:',
            style: TextStyle(
              color: primaryOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(specialistUpdate, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 12),

          // Photos Row
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder:
                  (context, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/electricity.png',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Show user comment if available - MOVED UP!
          if (userComments.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Comments:',
                  style: TextStyle(
                    color: primaryOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...userComments.map(
                  (comment) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(comment, style: const TextStyle(fontSize: 15)),
                  ),
                ),
              ],
            ),

          // User Comment Input + Send Button
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _commentController,
                  label: 'Your Comment',
                  icon: Icons.comment,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  if (_commentController.text.trim().isNotEmpty) {
                    setState(() {
                      userComments.add(_commentController.text.trim());
                      _commentController.clear();
                    });
                  }
                },

                child: const Text(
                  'Send',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
