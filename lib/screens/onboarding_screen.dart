import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.soup_kitchen,
      'title': 'Discover Recipes',
      'subtitle': 'Explore thousands of meals from around the world',
    },
    {
      'icon': Icons.manage_search,
      'title': 'Find By Category',
      'subtitle': 'Filter meals by cuisine, category, or ingredient',
    },
    {
      'icon': Icons.favorite_rounded,
      'title': 'Save Favourites',
      'subtitle': 'Keep your favourite recipes saved for offline access',
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // OPTIMIZED: Navigate immediately and save in background
  void _goToApp() {
    // Save setting in background - don't wait for it
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('onboarding_done', true);
    }).catchError((e) => debugPrint('Error saving onboarding: $e'));

    // Move to MainScreen immediately
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              'ONBOARDING',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 2.5,
                fontWeight: FontWeight.w900,
                color: Colors.black.withOpacity(0.4),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page['icon'] as IconData,
                            size: 80,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 60),
                        Text(
                          page['title'] as String,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          page['subtitle'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppTheme.textGrey,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppTheme.primary,
                      dotColor: AppTheme.primary.withOpacity(0.15),
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 4,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 65,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _controller.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _goToApp();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _goToApp,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppTheme.textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
