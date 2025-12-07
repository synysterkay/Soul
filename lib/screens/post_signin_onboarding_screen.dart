import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_plan/screens/welcome_screen.dart';

class PostSignInOnboardingScreen extends StatefulWidget {
  const PostSignInOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<PostSignInOnboardingScreen> createState() =>
      _PostSignInOnboardingScreenState();
}

class _PostSignInOnboardingScreenState
    extends State<PostSignInOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Welcome to SoulPlan!",
      description:
          "You're now part of a community creating meaningful connections",
      icon: Icons.celebration_rounded,
      color: Color(0xFFE91C40),
    ),
    OnboardingPage(
      title: "Your Personal Date Concierge",
      description: "We'll help you plan dates that match your style",
      icon: Icons.auto_awesome,
      color: Color(0xFFFF6B9D),
    ),
    OnboardingPage(
      title: "Find Perfect Venues",
      description:
          "Discover amazing restaurants, activities, and spots you've never tried before",
      icon: Icons.place_rounded,
      color: Color(0xFFE91C40),
    ),
    OnboardingPage(
      title: "Track Your Journey",
      description:
          "Build your relationship timeline with memories and experiences you'll cherish",
      icon: Icons.timeline_rounded,
      color: Color(0xFFFF6B9D),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Future<void> _handleContinue() async {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark post-signin onboarding as seen
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasSeenPostSignInOnboarding', true);

      if (!mounted) return;

      // Navigate to welcome screen (which leads to value prop, problem solution, before/after)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  void _skipToEnd() async {
    // Mark post-signin onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenPostSignInOnboarding', true);

    if (!mounted) return;

    // Navigate to welcome screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const WelcomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color(0xFFFFF5F7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Post Sign-In Setup',
                      style: GoogleFonts.raleway(
                        fontSize: 12,
                        color: Color(0xFF757575),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _skipToEnd,
                        child: Text(
                          'Skip',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            color: Color(0xFFE91C40),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Page indicator
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildIndicator(index == _currentPage),
                  ),
                ),
              ),

              // PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFE91C40),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    minimumSize: Size(double.infinity, 56),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Continue'
                        : 'Get Started',
                    style: GoogleFonts.raleway(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ).animate().fadeIn(delay: Duration(milliseconds: 800)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Color(0xFFE91C40) : Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: page.color.withOpacity(0.2),
                  blurRadius: 30,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 100,
              color: page.color,
            ),
          )
              .animate()
              .scale(
                delay: Duration(milliseconds: 200),
                duration: Duration(milliseconds: 600),
                curve: Curves.elasticOut,
              )
              .fadeIn(),

          SizedBox(height: 60),

          // Title
          Text(
            page.title,
            style: GoogleFonts.raleway(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 400))
              .slideY(begin: 0.3, end: 0),

          SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: GoogleFonts.raleway(
              fontSize: 18,
              height: 1.6,
              color: Color(0xFF757575),
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 600))
              .slideY(begin: 0.3, end: 0),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
