import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_plan/screens/before_after_screen.dart';

class ProblemSolutionScreen extends StatelessWidget {
  const ProblemSolutionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                SizedBox(height: 60),

                // Question Headline
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFE91C40).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    "Sound Familiar?",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91C40),
                      letterSpacing: 1,
                    ),
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),

                SizedBox(height: 24),

                Text(
                  "The Dating\nRut Problem",
                  style: GoogleFonts.lato(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2, end: 0),

                SizedBox(height: 48),

                // Problems
                _buildProblem(
                  icon: Icons.repeat,
                  title: "Same Old Dates",
                  description:
                      "Netflix and takeout... again? You're stuck in a repetitive routine that's killing the romance.",
                  delay: 600,
                ),

                SizedBox(height: 24),

                _buildProblem(
                  icon: Icons.question_mark,
                  title: "Planning Paralysis",
                  description:
                      "Spending hours scrolling through options but never deciding. \"Where should we go?\" \"I don't know, where do you want to go?\"",
                  delay: 800,
                ),

                SizedBox(height: 24),

                _buildProblem(
                  icon: Icons.money_off,
                  title: "Budget Stress",
                  description:
                      "Either overspending on mediocre dates or feeling guilty about being cheap. Never finding that sweet spot.",
                  delay: 1000,
                ),

                SizedBox(height: 24),

                _buildProblem(
                  icon: Icons.schedule,
                  title: "Time Wasted",
                  description:
                      "Hours researching restaurants, activities, and reviews only to be disappointed. Your precious time deserves better.",
                  delay: 1200,
                ),

                SizedBox(height: 48),

                // The Solution Callout
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFFE91C40),
                        Color(0xFFFF6B9D),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE91C40).withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: Colors.white,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "There's a Better Way",
                        style: GoogleFonts.lato(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Imagine having a personal AI assistant that knows both of your preferences, suggests amazing dates, and helps you plan everything in minutes.",
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.95),
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1400.ms).scale(),

                SizedBox(height: 48),

                // CTA
                Column(
                  children: [
                    Text(
                      "Ready to Transform Your Dates?",
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 1600.ms),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Mark problem solution screen as seen
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('hasSeenProblemSolution', true);

                          if (!context.mounted) return;

                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const BeforeAfterScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE91C40),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "See the Transformation",
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, size: 20),
                          ],
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 1800.ms)
                        .slideY(begin: 0.3, end: 0),
                  ],
                ),

                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProblem({
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey[700], size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.2, end: 0);
  }
}
