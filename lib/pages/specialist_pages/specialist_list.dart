import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import 'specialist_profile_view.dart';

class SpecialistList extends StatefulWidget {
  const SpecialistList({super.key});

  @override
  State<SpecialistList> createState() => _SpecialistListState();
}

class _SpecialistListState extends State<SpecialistList> {
  static const Color primaryOrange = Color(0xFFFFA726);

  final List<Map<String, String>> _specialists = [
    {
      'name': 'Ali Mansour',
      'specialty': 'Electrician',
      'location': 'Beirut',
      'rating': '4.7',
      'completedJobs': '32',
      'bio': 'Experienced electrician with fast and safe service.',
      'image': 'assets/profile_pic.png',
    },
    {
      'name': 'Rami Khoury',
      'specialty': 'Plumber',
      'location': 'Jounieh',
      'rating': '4.9',
      'completedJobs': '58',
      'bio': 'Reliable plumber, available 24/7.',
      'image': 'assets/profile_pic.png',
    },
    {
      'name': 'Lina Fares',
      'specialty': 'Painter',
      'location': 'Tripoli',
      'rating': '4.6',
      'completedJobs': '41',
      'bio': 'Creative painter for home and office décor.',
      'image': 'assets/profile_pic.png',
    },
    {
      'name': 'Hassan Saad',
      'specialty': 'Carpenter',
      'location': 'Saida',
      'rating': '4.8',
      'completedJobs': '27',
      'bio': 'Expert carpenter with custom furniture skills.',
      'image': 'assets/profile_pic.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: 'Specialists'),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver:
                _specialists.isEmpty
                    ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          "No specialists available",
                          style: TextStyle(fontSize: 18, color: primaryOrange),
                        ),
                      ),
                    )
                    : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final specialist = _specialists[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SpecialistProfileView(
                                      specialist: specialist,
                                    ),
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
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.asset(
                                    'assets/profile_pic.png',
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        specialist['name'] ?? 'No Name',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryOrange,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Specialty: ${specialist['specialty'] ?? 'N/A'}',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      Text(
                                        'Location: ${specialist['location'] ?? 'Unknown'}',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: _specialists.length),
                    ),
          ),
        ],
      ),
    );
  }
}
