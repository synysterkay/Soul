import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/date_request_service.dart';
import '../models/date_request_model.dart';
import 'questionnaire_screen.dart';
import 'partner_discovery_screen.dart';
import 'location_selection_screen.dart';

class QuestionnaireFlowScreen extends StatelessWidget {
  const QuestionnaireFlowScreen({Key? key}) : super(key: key);

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
          child: Column(
            children: [
              // Back Button
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Icon
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.people,
                          size: 64,
                          color: Color(0xFFE91C40),
                        ),
                      ).animate().scale(
                          delay: 200.ms,
                          duration: 600.ms,
                          curve: Curves.elasticOut),

                      const SizedBox(height: 32),

                      // Title
                      Text(
                        'How would you like\nto continue?',
                        style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 400.ms)
                          .slideY(begin: 0.3, end: 0),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        'Choose the best option for you and your partner',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 500.ms),

                      const SizedBox(height: 48),

                      // Option 1: Together
                      _OptionCard(
                        icon: Icons.devices,
                        title: 'Complete Together',
                        description: 'Your partner is with you right now',
                        details:
                            'Both of you will fill out the questionnaire together on this device',
                        color: Colors.white.withOpacity(0.15),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.4),
                        onTap: () async {
                          // For "Complete Together", both users are on the same device
                          // No need to have a pre-added partner
                          final currentUser = FirebaseAuth.instance.currentUser;
                          if (currentUser == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Please sign in first')),
                            );
                            return;
                          }

                          // First, ask for location
                          final locationData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const LocationSelectionScreen(),
                            ),
                          );

                          if (locationData == null || !context.mounted) {
                            return;
                          }

                          // Create a temporary partner ID for the session
                          // This represents the partner who is physically present
                          final tempPartnerId =
                              'temp_partner_${DateTime.now().millisecondsSinceEpoch}';

                          // Get current user's profile data to use for temp partner
                          final userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(currentUser.uid)
                              .get();

                          final userData = userDoc.data();

                          // Create a temporary user profile in Firestore for the partner
                          // Use same profile data as current user (they're together on same device)
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(tempPartnerId)
                              .set({
                            'uid': tempPartnerId,
                            'displayName': 'Partner',
                            'email': 'temp_${tempPartnerId}@soulplan.app',
                            'phoneNumber': userData?['phoneNumber'] ?? '',
                            'photoUrl': userData?['photoUrl'] ?? '',
                            'hobbies': userData?['hobbies'] ?? [],
                            'interests': userData?['interests'] ?? [],
                            'preferences': userData?['preferences'] ?? {},
                            'isTemporary': true,
                            'createdAt': FieldValue.serverTimestamp(),
                            'updatedAt': FieldValue.serverTimestamp(),
                          });

                          // Create date request for collaborative mode with location
                          final dateRequestService = DateRequestService();
                          final dateRequest =
                              await dateRequestService.createDateRequest(
                            initiatorId: currentUser.uid,
                            partnerId: tempPartnerId,
                            mode: DateRequestMode.collaborative,
                            location: locationData['location'],
                            locationCoords: locationData['coordinates'],
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => QuestionnaireScreen(),
                                settings: RouteSettings(
                                  arguments: {'dateRequestId': dateRequest.id},
                                ),
                              ),
                            );
                          }
                        },
                      )
                          .animate()
                          .fadeIn(delay: 600.ms)
                          .slideX(begin: -0.2, end: 0),

                      const SizedBox(height: 16),

                      // Option 2: Invite Partner
                      _OptionCard(
                        icon: Icons.send,
                        title: 'Invite Partner',
                        description: 'Send an invitation to your partner',
                        details:
                            'Your partner will complete their questionnaire separately on their device',
                        color: Colors.white.withOpacity(0.15),
                        textColor: Colors.white,
                        borderColor: Colors.white.withOpacity(0.4),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PartnerDiscoveryScreen(),
                            ),
                          );
                        },
                      )
                          .animate()
                          .fadeIn(delay: 700.ms)
                          .slideX(begin: 0.2, end: 0),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String details;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.details,
    required this.color,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: textColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lato(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          color: textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: textColor.withOpacity(0.6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      details,
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: textColor.withOpacity(0.8),
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
