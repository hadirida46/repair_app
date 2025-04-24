import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import 'job.dart'; // For 'waiting' jobs
import 'job_progress.dart'; // For 'in_progress' jobs

class SpecialistJobs extends StatefulWidget {
  const SpecialistJobs({super.key});

  @override
  State<SpecialistJobs> createState() => _SpecialistJobsState();
}

class _SpecialistJobsState extends State<SpecialistJobs> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final List<Map<String, String>> _jobs = [
    {
      'title': 'Broken Window',
      'date': '2024-07-20',
      'location': 'Beirut - Hamra',
      'description': 'A window in the living room is broken.',
      'status': 'waiting',
    },
    {
      'title': 'Leaking Sink',
      'date': '2024-07-21',
      'location': 'Beirut - Verdun',
      'description': 'The kitchen sink is leaking water.',
      'status': 'in_progress',
    },
    {
      'title': 'Electrical Shortage',
      'date': '2024-07-22',
      'location': 'Beirut - Ashrafieh',
      'description': 'There’s an electrical shortage in the office.',
      'status': 'waiting',
    },
    {
      'title': 'Cracked Wall',
      'date': '2024-07-23',
      'location': 'Beirut - Downtown',
      'description': 'A crack in the wall needs repair.',
      'status': 'in_progress',
    },
    {
      'title': 'Roof Damage',
      'date': '2024-07-24',
      'location': 'Beirut - Tallet El Khayyat',
      'description':
          'There’s significant roof damage that needs urgent repair.',
      'status': 'waiting',
    },
    {
      'title': 'Clogged Drain',
      'date': '2024-07-25',
      'location': 'Beirut - Cola',
      'description': 'The bathroom drain is clogged and needs attention.',
      'status': 'in_progress',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: 'Jobs'),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver:
                _jobs.isEmpty
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
                        final job = _jobs[index];
                        final String status = job['status'] ?? 'waiting';
                        final bool isInProgress = status == 'in_progress';

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        isInProgress
                                            ? JobProgressPage(job: job)
                                            : JobPage(job: job),
                              ),
                            );
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
                                      job['title'] ?? 'No Title',
                                      style: TextStyle(
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
                                  'Date: ${job['date'] ?? 'No Date'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                Text(
                                  'Location: ${job['location'] ?? 'Unknown'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Description: ${job['description'] ?? 'No Description'}',
                                  style: const TextStyle(
                                    fontStyle: FontStyle.italic,
                                  ),
                                  softWrap: true,
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _jobs.length),
                    ),
          ),
        ],
      ),
    );
  }
}
