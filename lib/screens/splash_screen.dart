import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:soul_plan/screens/welcome_screen.dart';
import 'package:soul_plan/screens/auth/login_screen.dart';
import 'package:soul_plan/screens/pre_onboarding_screen.dart';
import 'package:soul_plan/screens/post_signin_onboarding_screen.dart';
import 'package:soul_plan/screens/value_proposition_screen.dart';
import 'package:soul_plan/screens/problem_solution_screen.dart';
import 'package:soul_plan/screens/before_after_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _handleNavigation();
  }

  Future<void> _handleNavigation() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();

    // Check authentication status
    final user = context.read<User?>();

    if (user == null) {
      // ========== NOT LOGGED IN ==========
      // Show pre-signin onboarding screens
      final hasSeenPreOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      if (!hasSeenPreOnboarding) {
        // First time user, show pre-signin onboarding
        await prefs.setBool('hasSeenOnboarding', true);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const PreOnboardingScreen()),
        );
      } else {
        // Returning user who hasn't signed in, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    // ========== USER IS LOGGED IN ==========
    // Check onboarding flow progress
    final hasSeenPostSignInOnboarding =
        prefs.getBool('hasSeenPostSignInOnboarding') ?? false;
    final hasSeenWelcome = prefs.getBool('hasSeenWelcome') ?? false;
    final hasSeenValueProp = prefs.getBool('hasSeenValueProp') ?? false;
    final hasSeenProblemSolution =
        prefs.getBool('hasSeenProblemSolution') ?? false;

    // Flow: PostSignInOnboarding → Welcome → ValueProp → ProblemSolution → BeforeAfter (Superwall) → MainScreen
    // BeforeAfter screen ALWAYS appears before MainScreen - Superwall handles subscription logic

    if (!hasSeenPostSignInOnboarding) {
      // Show post-signin onboarding (first time logged in user)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const PostSignInOnboardingScreen()),
      );
    } else if (!hasSeenWelcome) {
      // Show welcome screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    } else if (!hasSeenValueProp) {
      // Show value proposition screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ValuePropositionScreen()),
      );
    } else if (!hasSeenProblemSolution) {
      // Show problem/solution screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const ProblemSolutionScreen()),
      );
    } else {
      // ALWAYS show before/after screen before MainScreen
      // Superwall inside BeforeAfterScreen handles subscription logic and navigation to MainScreen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const BeforeAfterScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91C40),
              Color(0xFFFF6B9D),
              Color(0xFFFFB4D6),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated circles background
            ...List.generate(5, (index) {
              return Positioned(
                left: (index * 80.0) - 40,
                top: (index * 120.0) - 60,
                child: AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: 150 + (index * 20.0),
                        height: 150 + (index * 20.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Main content
            Center(
              child: FadeTransition(
                opacity: _fadeController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated heart icon
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final scale = 1.0 + (_pulseController.value * 0.2);
                        return Transform.scale(
                          scale: scale,
                          child: Container(
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                  offset: Offset(0, 10),
                                ),
                                BoxShadow(
                                  color: Color(0xFFE91C40).withOpacity(0.4),
                                  blurRadius: 40,
                                  spreadRadius: 10,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.favorite,
                              size: 80,
                              color: Color(0xFFE91C40),
                            ),
                          ),
                        );
                      },
                    ).animate().scale(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        ),

                    SizedBox(height: 48),

                    // App name
                    Text(
                      'SoulPlan',
                      style: GoogleFonts.lato(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(
                          begin: 0.3,
                          end: 0,
                          duration: 600.ms,
                          curve: Curves.easeOut,
                        ),

                    SizedBox(height: 16),

                    // Tagline
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        'AI-Powered Date Planning',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).scale(
                          duration: 400.ms,
                          curve: Curves.easeOut,
                        ),

                    SizedBox(height: 80),

                    // Loading indicator
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ).animate().fadeIn(delay: 800.ms),

                    SizedBox(height: 16),

                    Text(
                      'Loading your perfect dates...',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 1000.ms),
                  ],
                ),
              ),
            ),

            // Version or branding at bottom
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Crafting Unforgettable Memories',
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
