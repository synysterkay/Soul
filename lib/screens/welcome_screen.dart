import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_plan/screens/value_proposition_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91C40),
              Color(0xFFFF6B9D),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                Spacer(flex: 2),

                // App Icon/Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 80,
                    color: Color(0xFFE91C40),
                  ),
                )
                    .animate()
                    .scale(
                        delay: 300.ms,
                        duration: 600.ms,
                        curve: Curves.elasticOut)
                    .shimmer(delay: 900.ms, duration: 1000.ms),

                SizedBox(height: 48),

                // Welcome Text
                Text(
                  "Welcome to",
                  style: GoogleFonts.lato(
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 600.ms),

                SizedBox(height: 8),

                Text(
                  "SoulPlan",
                  style: GoogleFonts.lato(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, end: 0),

                SizedBox(height: 24),

                // Tagline
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Text(
                    "AI-Powered Date Planning",
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(delay: 900.ms).scale(),

                SizedBox(height: 48),

                // Subtitle
                Text(
                  "Stop planning boring dates.\nStart creating unforgettable memories.",
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.95),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 1100.ms),

                Spacer(flex: 3),

                // Get Started Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark welcome screen as seen
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenWelcome', true);

                      if (!context.mounted) return;

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ValuePropositionScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFFE91C40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.3),
                    ),
                    child: Text(
                      "Get Started",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1300.ms).slideY(begin: 0.3, end: 0),

                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
