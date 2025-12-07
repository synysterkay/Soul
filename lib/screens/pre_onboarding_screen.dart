import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_plan/screens/auth/login_screen.dart';

class PreOnboardingScreen extends StatefulWidget {
  const PreOnboardingScreen({Key? key}) : super(key: key);

  @override
  State<PreOnboardingScreen> createState() => _PreOnboardingScreenState();
}

class _PreOnboardingScreenState extends State<PreOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Transform Your Dating Life",
      description:
          "Get personalized date plans that match both your personalities and preferences",
      icon: Icons.favorite_rounded,
      color: Color(0xFFE91C40),
    ),
    OnboardingPage(
      title: "AI-Powered Intelligence",
      description:
          "Our smart AI learns what makes you both happy and suggests perfect experiences",
      icon: Icons.auto_awesome,
      color: Color(0xFFFF6B9D),
    ),
    OnboardingPage(
      title: "Build Deeper Connections",
      description:
          "Strengthen your bond with thoughtful dates designed to bring you closer",
      icon: Icons.psychology_alt_rounded,
      color: Color(0xFFE91C40),
    ),
    OnboardingPage(
      title: "Ready to Begin?",
      description:
          "Join thousands of couples creating unforgettable moments together",
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFFFF6B9D),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _skipToEnd() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipToEnd,
                  child: Text(
                    'Skip',
                    style: GoogleFonts.lato(
                      color: Color(0xFF757575),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_pages[index]);
                  },
                ),
              ),

              // Page indicators
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 32 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Color(0xFFE91C40)
                            : Color(0xFFE0E0E0),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    )
                        .animate(
                          target: _currentPage == index ? 1 : 0,
                        )
                        .scaleX(
                          duration: 300.ms,
                          curve: Curves.easeInOut,
                        ),
                  ),
                ),
              ),

              // Next button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91C40),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                      shadowColor: Color(0xFFE91C40).withOpacity(0.3),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Continue',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Color(0xFFFFF5F7),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE91C40).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              page.icon,
              size: 80,
              color: Color(0xFFE91C40),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                delay: 500.ms,
                duration: 2000.ms,
                begin: Offset(1.0, 1.0),
                end: Offset(1.1, 1.1),
                curve: Curves.easeInOut,
              ),

          const SizedBox(height: 60),

          // Title
          Text(
            page.title,
            style: GoogleFonts.lato(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 24),

          // Description
          Text(
            page.description,
            style: GoogleFonts.lato(
              fontSize: 18,
              color: Color(0xFF757575),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
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
