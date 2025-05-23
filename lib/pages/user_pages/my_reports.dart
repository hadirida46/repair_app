import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import '/widgets/report_status.dart';
import 'specialist_list.dart';
import 'job_tracking.dart';
import 'feedback.dart';
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MyReports extends StatefulWidget {
  const MyReports({super.key});

  @override
  State<MyReports> createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  static const Color primaryOrange = Color(0xFFFFA726);

  List<dynamic> _reports = [];

  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    final token = await storage.read(key: 'auth_token');
    debugPrint('Token: $token');

    final response = await http.get(
      Uri.parse('$baseUrl/user/reports'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    debugPrint('Response status: ${response.statusCode}');
    debugPrint('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint('Response Data: $data');

      setState(() {
        _reports = data['reports'] ?? [];
      });
    } else {
      debugPrint('Failed to load reports: ${response.body}');
    }
  }

  Future<void> _deleteReportFromApi(int reportId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await http.delete(
      Uri.parse('$baseUrl/reports/$reportId'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      debugPrint('Report deleted successfully');
      fetchReports();
    } else {
      debugPrint('Failed to delete report: ${response.body}');
    }
  }

  void _handleReportNavigation(Map<String, dynamic> report) {
    final status = report['status'];
    final reportId = report['id'];
    final specialistId = report['specialist_id'];
    if (status == 'in progress' && reportId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => JobTrackingPage(job: report)),
      );
    } else if (status == 'completed' && reportId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => FeedbackPage(
                reportId: reportId as int,
                specialistId: specialistId as int,
              ),
        ),
      );
    } else if (status == 'rejected' ||
        status == 'waiting' ||
        status == 'escalated') {
      _showReportMenu(report);
    }
  }

  Future<void> _showDeleteConfirmation(int index, int reportId) async {
    bool confirmDelete = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Do you really want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () {
                confirmDelete = true;
                Navigator.of(context).pop();
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
            ),
          ],
        );
      },
    );

    if (confirmDelete) {
      await _deleteReportFromApi(reportId);
      setState(() {
        _reports.removeAt(index);
      });
    }
  }

  void _showReportMenu(Map<String, dynamic> reportData) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reportData['title'] ?? 'Report Menu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Report'),
                onTap: () {
                  Navigator.pop(context);
                  final int? reportId = reportData['id'];
                  final int index = _reports.indexOf(reportData);
                  if (reportId != null && index != -1) {
                    _showDeleteConfirmation(index, reportId);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.search, color: primaryOrange),
                title: const Text('Search for New Specialist'),
                onTap: () {
                  Navigator.pop(context);
                  final int? reportId = reportData['id'];
                  if (reportId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                SpecialistList(reportId: reportId as int),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchReports,
        child: CustomScrollView(
          slivers: [
            const CustomAppBar(title: 'My Reports'),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver:
                  _reports.isEmpty
                      ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              "No reports yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: primaryOrange,
                              ),
                            ),
                          ),
                        ),
                      )
                      : SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final report = _reports[index];
                          debugPrint('Rendering Report: $report');
                          String formattedDate = '';
                          if (report['created_at'] != null &&
                              report['created_at'].isNotEmpty) {
                            try {
                              formattedDate = DateFormat(
                                'yyyy-MM-dd',
                              ).format(DateTime.parse(report['created_at']));
                            } catch (e) {
                              formattedDate = 'No Date';
                            }
                          } else {
                            formattedDate = 'No Date';
                          }
                          return GestureDetector(
                            onTap: () => _handleReportNavigation(report),

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
                                  Text(
                                    report['title'] ?? 'No Title',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: primaryOrange,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Date: $formattedDate',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Text(
                                        'Status: ',
                                        style: TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      ReportStatus(
                                        status: report['status'] ?? 'Unknown',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Description: ${report['description'] ?? 'No Description'}',
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                    ),
                                    softWrap: true,
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
      ),
    );
  }
}
