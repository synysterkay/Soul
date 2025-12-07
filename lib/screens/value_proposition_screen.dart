import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soul_plan/screens/problem_solution_screen.dart';

class ValuePropositionScreen extends StatelessWidget {
  const ValuePropositionScreen({Key? key}) : super(key: key);

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

                // Main Headline
                Text(
                  "Why Couples Love\nSoulPlan",
                  style: GoogleFonts.lato(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2, end: 0),

                SizedBox(height: 16),

                Text(
                  "Join thousands of couples creating\namazing memories together",
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Color(0xFF757575),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 400.ms),

                SizedBox(height: 48),

                // Value Props
                _buildValueProp(
                  icon: Icons.psychology,
                  color: Color(0xFFE91C40),
                  title: "AI-Powered Personalization",
                  description:
                      "Get date ideas tailored specifically to both of your interests, mood, and budget.",
                  delay: 600,
                ),

                SizedBox(height: 32),

                _buildValueProp(
                  icon: Icons.explore,
                  color: Color(0xFF9C27B0),
                  title: "Discover Hidden Gems",
                  description:
                      "Find amazing local spots and activities you never knew existed in your area.",
                  delay: 800,
                ),

                SizedBox(height: 32),

                _buildValueProp(
                  icon: Icons.timeline,
                  color: Color(0xFF2196F3),
                  title: "Collaborative Planning",
                  description:
                      "Plan dates together in real-time with your partner. No more endless back-and-forth texts.",
                  delay: 1000,
                ),

                SizedBox(height: 32),

                _buildValueProp(
                  icon: Icons.favorite,
                  color: Color(0xFFFF5722),
                  title: "Keep the Spark Alive",
                  description:
                      "Break the routine with fresh, exciting date ideas that bring you closer together.",
                  delay: 1200,
                ),

                SizedBox(height: 48),

                // Social Proof
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF0F3),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: Color(0xFFE91C40).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          5,
                          (index) => Icon(Icons.star,
                              color: Color(0xFFFFB300), size: 24),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '"SoulPlan transformed our relationship! We went from boring dinner dates to exciting adventures."',
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF2E2E2E),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "- Sarah & Mike, together 3 years",
                        style: GoogleFonts.lato(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE91C40),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 1400.ms).scale(),

                SizedBox(height: 48),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark value prop screen as seen
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('hasSeenValueProp', true);

                      if (!context.mounted) return;

                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const ProblemSolutionScreen(),
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
                          "Continue",
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
                ).animate().fadeIn(delay: 1600.ms).slideY(begin: 0.3, end: 0),

                SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueProp({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
    required int delay,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
              ),
              SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: Color(0xFF757575),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: delay.ms).slideX(begin: -0.2, end: 0);
  }
}
