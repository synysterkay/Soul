import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:soul_plan/screens/main_screen.dart';
import 'package:superwallkit_flutter/superwallkit_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BeforeAfterScreen extends StatelessWidget {
  const BeforeAfterScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Headline
              Text(
                "See the Difference with SoulPlan",
                style: GoogleFonts.lato(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E2E2E),
                ),
                textAlign: TextAlign.left,
              ).animate().fadeIn(delay: const Duration(milliseconds: 200)),

              const SizedBox(height: 16),

              // Subtitle
              Text(
                "Transform your relationship with our personalized date plans",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: const Color(0xFF757575),
                ),
                textAlign: TextAlign.left,
              ).animate().fadeIn(delay: const Duration(milliseconds: 300)),

              const SizedBox(height: 40),

              // BEFORE section
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // BEFORE section
                      _buildSection(
                        title: "BEFORE",
                        items: [
                          "Repetitive dates that feel like a routine",
                          "Struggling to find new ideas that excite both of you",
                          "Spending too much money on mediocre experiences",
                          "Feeling disconnected and taking each other for granted",
                          "Stress and anxiety about planning the perfect date",
                        ],
                        isGrayscale: true,
                        icon: Icons.sentiment_dissatisfied,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 400)),

                      // Divider with arrow
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                            Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE91C40).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                color: Color(0xFFE91C40),
                                size: 24,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 600)),

                      // AFTER section
                      _buildSection(
                        title: "AFTER",
                        items: [
                          "Fresh, unique experiences tailored to your preferences",
                          "Exciting dates that both of you will look forward to",
                          "Budget-friendly options that don't sacrifice quality",
                          "Deeper connection and renewed appreciation for each other",
                          "Effortless planning with our AI-powered recommendations",
                        ],
                        isGrayscale: false,
                        icon: Icons.sentiment_very_satisfied,
                      )
                          .animate()
                          .fadeIn(delay: const Duration(milliseconds: 800)),
                    ],
                  ),
                ),
              ),

              // CTA Button
              Container(
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: ElevatedButton(
                  onPressed: () async {
                    // NO LONGER saving hasSeenBeforeAfter flag
                    // We want this screen to always appear before MainScreen

                    if (kIsWeb) {
                      // On web, skip paywall and go directly to main screen
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => MainScreen()),
                      );
                    } else {
                      // On mobile (Android & iOS), show Superwall paywall
                      // Superwall dashboard handles gating logic
                      Superwall.shared.registerPlacement(
                        'app_access',
                        feature: () {
                          // Navigate to main screen when user has access
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (context) => MainScreen()),
                          );
                        },
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE91C40),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFE91C40).withOpacity(0.3),
                  ),
                  child: Text(
                    "Start My Personalized Plan",
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: const Duration(milliseconds: 1000)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required bool isGrayscale,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isGrayscale ? Colors.grey.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGrayscale
              ? Colors.grey.shade300
              : const Color(0xFFE91C40).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isGrayscale
                ? Colors.grey.withOpacity(0.2)
                : const Color(0xFFE91C40).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isGrayscale
                      ? Colors.grey.shade300
                      : const Color(0xFFE91C40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: isGrayscale
                      ? Colors.grey.shade600
                      : const Color(0xFFE91C40),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isGrayscale
                      ? Colors.grey.shade700
                      : const Color(0xFFE91C40),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Divider
          Container(
            height: 1,
            color: isGrayscale
                ? Colors.grey.shade300
                : const Color(0xFFE91C40).withOpacity(0.2),
          ),

          const SizedBox(height: 24),

          // List items
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      child: Icon(
                        isGrayscale ? Icons.remove_circle : Icons.check_circle,
                        size: 18,
                        color: isGrayscale
                            ? Colors.grey.shade500
                            : const Color(0xFFE91C40),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          height: 1.5,
                          color: isGrayscale
                              ? Colors.grey.shade600
                              : const Color(0xFF2E2E2E),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
