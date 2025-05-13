import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import 'job.dart';
import 'job_progress.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants.dart';
import 'package:intl/intl.dart';

const Color primaryOrange = Color(0xFFFFA726);

class SpecialistJobs extends StatefulWidget {
  const SpecialistJobs({super.key});

  @override
  State<SpecialistJobs> createState() => _SpecialistJobsState();
}

class _SpecialistJobsState extends State<SpecialistJobs>
    with WidgetsBindingObserver {
  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'No Date';
    try {
      return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateStr));
    } catch (e) {
      return 'Invalid Date';
    }
  }

  @override
  void initState() {
    super.initState();
    fetchReports();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchReports();
    }
  }

  Future<void> fetchReports() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reports/assigned'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List reports = data['reports'];
        setState(() {
          _reports = List<Map<String, dynamic>>.from(reports);
          _isLoading = false;
        });
      } else {
        print("Failed to load jobs: ${response.body}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: 'Jobs'),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver:
                _reports.isEmpty
                    ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "No jobs assigned yet",
                          style: TextStyle(fontSize: 18, color: primaryOrange),
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final report = _reports[index];
                        final String status = report['status'];
                        final bool isInProgress = status == 'in progress';
                        final String formattedDate = _formatDate(
                          report['created_at'],
                        );

                        if (status != 'waiting' && !isInProgress) {
                          return const SizedBox.shrink();
                        }
                        final imageUrl =
                            report['images'] != null &&
                                    report['images'].isNotEmpty
                                ? report['images'][0] 
                                : 'https://example.com/fallback_image.jpg'; 

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        isInProgress
                                            ? JobProgressPage(job: report)
                                            : JobPage(job: report),
                              ),
                            ).then((_) {
                              fetchReports();
                            });
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      report['title'] ?? 'No Title',
                                      style: const TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: primaryOrange,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isInProgress
                                                ? Colors.blue
                                                : Colors.grey,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isInProgress
                                            ? 'In Progress'
                                            : 'Waiting',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Date: $formattedDate',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  'Location: ${report['location'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${report['description'] ?? 'No Description'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 8),
                                Image.network(
                                  imageUrl, 
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text('Image failed to load.'),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _reports.length),
                    ),
          ),
        ],
      ),
    );
  }
}
