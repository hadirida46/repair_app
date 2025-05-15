import 'dart:async';
import 'package:flutter/material.dart';
import '/widgets/custom_appbar.dart';
import '/widgets/expert_card.dart';

const Color primaryOrange = Color(0xFFFF9800);

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
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

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
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
                            "Home or office,\nwe've got your back",
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
                          "Got a problem at your home or office? Whether it’s a leak, a wiring issue, or something else — we’ve got your back. Just report the issue, snap a photo, and let our app connect you with trusted specialists in your area. From real-time chat to progress tracking, we make fixing things simple and stress-free.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          "Our Work",
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
