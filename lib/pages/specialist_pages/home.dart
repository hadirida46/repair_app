import 'dart:async';
import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import '/widgets/expert_card.dart';

const Color primaryOrange = Color(0xFFFF9800);

class SpecialistHome extends StatefulWidget {
  const SpecialistHome({super.key});

  @override
  State<SpecialistHome> createState() => _SpecialistHomeState();
}

class _SpecialistHomeState extends State<SpecialistHome> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final PageController _testimonialController = PageController();
  int _currentTestimonial = 0;
  Timer? _testimonialTimer;

  final List<Map<String, String>> _reports = [
    {
      'image': 'assets/plumbing.png',
      'title': 'Leaking Kitchen Sink',
      'specialist': 'Handled by: Ahmad the Plumber',
    },
    {
      'image': 'assets/electricity.png',
      'title': 'Office Power Issue',
      'specialist': 'Handled by: Ahmad the Electrician',
    },
    {
      'image': 'assets/architecture.png',
      'title': 'Garage Wall Crack',
      'specialist': 'Handled by: Jad the Engineer',
    },
  ];

  final List<Map<String, String>> _testimonials = [
    {
      'quote':
          'John fixed my office wall in no time. Super professional and polite.”',
      'author': '- Rana K.',
    },
    {
      'quote': '“Booking a plumber was so easy! Got help the same day.”',
      'author': '- Ali H.',
    },
    {
      'quote':
          '“Really impressed by how fast John arrived and fixed our lights.”',
      'author': '- Mira S.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
    _startTestimonialScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (_pageController.hasClients) {
        setState(() {
          _currentPage = (_currentPage + 1) % _reports.length;
        });
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _startTestimonialScroll() {
    _testimonialTimer = Timer.periodic(const Duration(seconds: 6), (
      Timer timer,
    ) {
      if (_testimonialController.hasClients) {
        setState(() {
          _currentTestimonial =
              (_currentTestimonial + 1) % _testimonials.length;
        });
        _testimonialController.animateToPage(
          _currentTestimonial,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _timer?.cancel();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _testimonialController.dispose();
    _timer?.cancel();
    _testimonialTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const CustomAppBar(title: 'Home'),
            SliverPadding(
              padding: const EdgeInsets.all(20.0),
              sliver: SliverFillRemaining(
                hasScrollBody: true,
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
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
                        const SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Keep me busy,\nI’m built for it",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Lobster',
                              fontSize: 28,
                              color: primaryOrange,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "You're an expert in your field, trusted by those who rely on your skills. Every task you take on helps someone live or work better. Keep working with honesty, dedication, and pride — because real impact comes from doing good work, the right way.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "My Work",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: _reports.length,
                            onPageChanged: _onPageChanged,
                            itemBuilder: (context, index) {
                              final report = _reports[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        report['image']!,
                                        fit: BoxFit.cover,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.black.withOpacity(0.6),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        left: 10,
                                        right: 10,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              report['title']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              report['specialist']!,
                                              style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "About Me",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: PageView.builder(
                            controller: _testimonialController,
                            itemCount: _testimonials.length,
                            itemBuilder: (context, index) {
                              final testimonial = _testimonials[index];
                              return Container(
                                padding: const EdgeInsets.all(15),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: primaryOrange.withOpacity(0.4),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      testimonial['quote']!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      testimonial['author']!,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          "Nearby Mates 📍",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryOrange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var expert in [
                                    {'name': 'Ahmad', 'job': 'Plumber'},
                                    {'name': 'Sara', 'job': 'Electrician'},
                                    {'name': 'Jad', 'job': 'Engineer'},
                                    {'name': 'Layla', 'job': 'Architect'},
                                    {'name': 'Omar', 'job': 'Plumber'},
                                    {'name': 'Nadia', 'job': 'Electrician'},
                                  ])
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: ExpertCard(
                                        imagePath: 'assets/profile_pic.png',
                                        name: expert['name']!,
                                        job: expert['job']!,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Positioned(
                              right: 0,
                              top: 10,
                              child: GestureDetector(
                                onTap: () {
                                  // Add scroll logic if needed
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward_ios,
                                    color: primaryOrange,
                                  ),
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
          ],
        ),
      ),
    );
  }
}
