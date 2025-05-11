import 'package:flutter/material.dart';
import 'specialist_profile_view.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/custom_appbar.dart';
import 'main_page.dart';

class SpecialistList extends StatefulWidget {
  final int reportId;
  const SpecialistList({super.key, required this.reportId});

  @override
  State<SpecialistList> createState() => _SpecialistListState();
}

class _SpecialistListState extends State<SpecialistList> {
  static const Color primaryOrange = Color(0xFFFFA726);
  final _storage = const FlutterSecureStorage();
  final List<Map<String, dynamic>> _specialists = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchSpecialists();
  }

  Future<void> fetchSpecialists() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final reportId = widget.reportId;
    final url = Uri.parse('$baseUrl/reports/$reportId/specialists');
    final token = await _storage.read(key: 'auth_token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _specialists.clear();
          _specialists.addAll(data.cast<Map<String, dynamic>>());
        });
      } else {
        setState(() {
          _error = 'Failed to fetch specialists.';
        });
        debugPrint('Failed to fetch specialists: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching specialists.';
      });
      debugPrint('Error fetching specialists: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          const CustomAppBar(title: 'Specialist List'),
          SliverPadding(
            padding: const EdgeInsets.all(20.0),
            sliver:
                _isLoading
                    ? const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : _error != null
                    ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _error!,
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: fetchSpecialists,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                    : _specialists.isEmpty
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
                        final String? profileImageUrl =
                            specialist['profile_image'] as String?;
                        final String firstName =
                            specialist['first_name'] as String? ?? '';
                        final String lastName =
                            specialist['last_name'] as String? ?? '';
                        final Map<String, String> specialistStringMap = {
                          for (var entry in specialist.entries)
                            entry.key: entry.value.toString(),
                        };

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => SpecialistProfileView(
                                      specialist: specialistStringMap,
                                      reportId: widget.reportId,
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
                                  child:
                                      profileImageUrl != null &&
                                              profileImageUrl.isNotEmpty
                                          ? Image.network(
                                            profileImageUrl,
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Image.asset(
                                                'assets/profile_pic.png',
                                                width: 60,
                                                height: 60,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                          )
                                          : Image.asset(
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
                                        '$firstName $lastName'.trim(),
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: primaryOrange,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'specialization: ${specialist['specialization'] ?? 'N/A'}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainPage(initialIndex: 1)),
            (route) => false,
          );
        },
        child: const Icon(Icons.assignment, color: Colors.white),
        backgroundColor: primaryOrange,
      ),
    );
  }
}
