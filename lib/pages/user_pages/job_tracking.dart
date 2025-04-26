import 'package:flutter/material.dart';

class JobTrackingPage extends StatelessWidget {
  const JobTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy list of progress images (duplicated for two entries)
    final List<String> progressImages = [
      'assets/electricity.png',
      'assets/electricity.png',
    ];

    // Dummy comments for each image
    final List<String> progressComments = [
      'Replaced faulty wiring and checked voltage.',
      'Installed new socket and tested power flow.',
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Job Tracking',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.indigo[900],
      ),
      body: SingleChildScrollView(
        // Added SingleChildScrollView for better mobile responsiveness
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Job Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  // Added shadow
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3), // changes position of shadow
                  ),
                ],
                border: Border.all(
                  color: Colors.grey.shade200,
                ), // Refined border
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Electrician Job',
                    style: TextStyle(
                      color: Colors.indigo, // Changed color for better contrast
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Handled by: John Doe',
                    style: TextStyle(color: Colors.black87),
                  ), // Improved text color
                  Text(
                    'Start Date: 2025-04-24',
                    style: TextStyle(color: Colors.black87),
                  ),
                  Text(
                    'Description: Fixing indoor unit not cooling properly.',
                    style: TextStyle(color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Progress Images Title
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Progress Updates:', // More descriptive title
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo, // Consistent color
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Progress Images List
            progressImages.isEmpty
                ? const Text('No progress images uploaded yet.')
                : SizedBox(
                  height: 220, // Adjusted height for better mobile view
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: progressImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width:
                            MediaQuery.of(context).size.width *
                            0.8, // Adjusted width for better mobile view
                        margin: const EdgeInsets.only(
                          right: 15,
                          bottom: 10,
                        ), // Added bottom margin
                        padding: const EdgeInsets.all(12), // Adjusted padding
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            // Added shadow
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.grey.shade200,
                          ), // Refined border
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              progressComments[index],
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black87, // Improved text color
                              ),
                              maxLines:
                                  2, // Added maxLines for better text overflow
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio: 16 / 9,
                                  child: Image.asset(
                                    progressImages[index],
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
