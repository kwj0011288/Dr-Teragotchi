// main onboarding page with animated background
import 'package:flutter/material.dart';
import 'package:emogotchi/pages/onboard/onboarding1.dart';
import 'package:emogotchi/pages/onboard/onboarding2.dart';
import 'package:emogotchi/pages/onboard/onboarding3.dart';
import 'package:emogotchi/pages/onboard/onboarding4.dart';

class OnboardPage extends StatefulWidget {
  const OnboardPage({super.key});

  @override
  State<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends State<OnboardPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> _backgroundImages = [
    'assets/background/park.png',
    'assets/background/lake.png',
    'assets/background/airport.png',
    'assets/background/school.png',
  ];

  final List<Widget> _pages = [
    Onboarding1(),
    Onboarding2(),
    Onboarding3(),
    Onboarding4(),
  ];

  void _goToNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, '/namepage');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Image.asset(
              _backgroundImages[_currentPage],
              key: ValueKey(_backgroundImages[_currentPage]),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.3)),
          PageView(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() => _currentPage = page);
            },
            children: _pages,
          ),
          if (_currentPage < _pages.length - 1)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_pages.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 16 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}
