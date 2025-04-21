import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import '/widgets/report_status.dart';

class MyReports extends StatefulWidget {
  const MyReports({super.key});

  @override
  State<MyReports> createState() => _MyReportsState();
}

class _MyReportsState extends State<MyReports> {
  static const Color primaryOrange = const Color(0xFFFFA726);

  final List<Map<String, String>> _reports = [
    // Dummy data
    {
      'title': 'Broken Window',
      'date': '2024-07-20',
      'status': 'Waiting For Confirmation',
      'description': 'A window in the living room is broken.',
    },
    {
      'title': 'Leaking Sink',
      'date': '2024-07-21',
      'status': 'Accepted',
      'description': 'The kitchen sink is leaking water.',
    },
    {
      'title': 'Electrical Shortage',
      'date': '2024-07-22',
      'status': 'Completed',
      'description': 'There’s an electrical shortage in the office.',
    },
    {
      'title': 'Cracked Wall',
      'date': '2024-07-23',
      'status': 'Rejected',
      'description': 'A crack in the wall needs repair.',
    },
    {
      'title': 'Roof Damage',
      'date': '2024-07-24',
      'status': 'Escalated',
      'description':
          'There’s significant roof damage that needs urgent repair.',
    },
    {
      'title': 'Clogged Drain',
      'date': '2024-07-25',
      'status': 'In Progress',
      'description': 'The bathroom drain is clogged and needs attention.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
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
                        return Container(
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
                                'Date: ${report['date'] ?? 'No Date'}',
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
                        );
                      }, childCount: _reports.length),
                    ),
          ),
        ],
      ),
    );
  }
}
