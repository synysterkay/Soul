import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import '../post_signin_onboarding_screen.dart';

class PhoneInputScreen extends StatefulWidget {
  const PhoneInputScreen({super.key});

  @override
  State<PhoneInputScreen> createState() => _PhoneInputScreenState();
}

class _PhoneInputScreenState extends State<PhoneInputScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _savePhoneNumber() async {
    final phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your phone number with country code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!phoneNumber.startsWith('+')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please include country code (e.g., +1, +44, +91)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (phoneNumber.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = context.read<User?>();
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Save phone number to Firestore (not verified, but stored for discovery)
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'phoneNumber': phoneNumber,
        'phoneVerified': false, // Mark as not verified
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PostSignInOnboardingScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving phone number: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _skipForNow() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const PostSignInOnboardingScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom -
                    48,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Color(0xFF2E2E2E)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Add Your Phone Number',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'This helps your friends find you on Soul Plan. We won\'t share your number without permission.',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Color(0xFF757575),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Phone number input with country code
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Color(0xFF2E2E2E),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        labelStyle: GoogleFonts.lato(
                          color: Color(0xFF757575),
                        ),
                        hintText: '+1 234 567 8900',
                        hintStyle: GoogleFonts.lato(
                          color: Color(0xFFBDBDBD),
                        ),
                        helperText: 'Include country code (e.g., +1, +44, +91)',
                        helperStyle: GoogleFonts.lato(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                        ),
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: Color(0xFFE91C40),
                        ),
                        filled: true,
                        fillColor: Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFFE91C40),
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Info text
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF5F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFFFE4EA),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFFE91C40),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No verification required now. We\'ll use this to help you connect with friends.',
                              style: GoogleFonts.lato(
                                fontSize: 13,
                                color: Color(0xFF757575),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePhoneNumber,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFE91C40),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          shadowColor: Color(0xFFE91C40).withOpacity(0.3),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Continue',
                                style: GoogleFonts.raleway(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Skip button
                    TextButton(
                      onPressed: _skipForNow,
                      style: TextButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: Text(
                        'Skip for now',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Color(0xFF757575),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
