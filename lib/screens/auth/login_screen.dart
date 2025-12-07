import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'phone_input_screen.dart';
import '../post_signin_onboarding_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openPrivacyPolicy() async {
    final uri = Uri.parse('https://sites.google.com/view/soulplan');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Privacy Policy')),
        );
      }
    }
  }

  Future<void> _openTermsOfService() async {
    final uri = Uri.parse('https://sites.google.com/view/soulplanterms');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Terms of Service')),
        );
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signInWithGoogle();

      if (userCredential == null || !mounted) {
        setState(() => _isLoading = false);
        return;
      }

      // Check if user has phone number
      final userData = await _authService.getUserData(userCredential.user!.uid);
      final phoneNumber = userData?.phoneNumber;

      if (phoneNumber == null || phoneNumber.isEmpty) {
        // No phone number, go to phone input
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const PhoneInputScreen(),
          ),
        );
      } else {
        // Has phone number, check if they've seen post-signin onboarding
        final prefs = await SharedPreferences.getInstance();
        final hasSeenPostSignInOnboarding =
            prefs.getBool('hasSeenPostSignInOnboarding') ?? false;

        if (!hasSeenPostSignInOnboarding) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PostSignInOnboardingScreen(),
            ),
          );
        } else {
          Navigator.pushReplacementNamed(context, '/splash');
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign In failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: ${e.toString()}'),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain an uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain a lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain a number';
    }
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain a special character';
    }
    return null;
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        // Sign up with email/password
        final userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Send email verification
        await userCredential.user?.sendEmailVerification();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Verification email sent! Please check your inbox.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );

          // Navigate to phone input
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const PhoneInputScreen(),
            ),
          );
        }
      } else {
        // Sign in with email/password
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Check if email is verified
        if (userCredential.user?.emailVerified == false) {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Please verify your email first. Check your inbox.'),
                backgroundColor: Colors.orange,
                action: SnackBarAction(
                  label: 'Resend',
                  textColor: Colors.white,
                  onPressed: () async {
                    await userCredential.user?.sendEmailVerification();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Verification email sent!')),
                    );
                  },
                ),
                duration: Duration(seconds: 6),
              ),
            );
          }
          return;
        }

        if (mounted) {
          // Check if user has phone number
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .get();

          final phoneNumber = userDoc.data()?['phoneNumber'];

          if (phoneNumber == null || phoneNumber.isEmpty) {
            // No phone number, go to phone input
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const PhoneInputScreen(),
              ),
            );
          } else {
            // Has phone number, check if they've seen post-signin onboarding
            final prefs = await SharedPreferences.getInstance();
            final hasSeenPostSignInOnboarding =
                prefs.getBool('hasSeenPostSignInOnboarding') ?? false;

            if (!hasSeenPostSignInOnboarding) {
              // First time after adding phone, show post-signin onboarding
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostSignInOnboardingScreen(),
                ),
              );
            } else {
              // Has seen onboarding, let splash screen handle the rest of the flow
              Navigator.pushReplacementNamed(context, '/splash');
            }
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      switch (e.code) {
        case 'email-already-in-use':
          message = 'This email is already registered';
          break;
        case 'invalid-email':
          message = 'Invalid email address';
          break;
        case 'user-not-found':
          message = 'No account found with this email';
          break;
        case 'wrong-password':
          message = 'Incorrect password';
          break;
        case 'weak-password':
          message = 'Password is too weak';
          break;
        case 'network-request-failed':
          message = 'Network error. Check your connection';
          break;
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent! Check your inbox.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error sending reset email';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 40),

                  // Top Section - Logo and Title
                  Column(
                    children: [
                      // Animated Logo
                      Hero(
                        tag: 'app_logo',
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFE91C40),
                                Color(0xFFFF6B9D),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFE91C40).withOpacity(0.3),
                                blurRadius: 30,
                                offset: Offset(0, 10),
                                spreadRadius: -5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.favorite_rounded,
                            size: 70,
                            color: Colors.white,
                          ),
                        ),
                      ).animate().fadeIn(duration: 600.ms).scale(
                          delay: 200.ms,
                          duration: 500.ms,
                          curve: Curves.elasticOut),

                      const SizedBox(height: 32),

                      // App Name
                      Text(
                        'Soul Plan',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E2E2E),
                          letterSpacing: -1,
                        ),
                      )
                          .animate()
                          .fadeIn(delay: 400.ms, duration: 600.ms)
                          .slideY(
                              begin: 0.3,
                              end: 0,
                              delay: 400.ms,
                              duration: 600.ms),

                      const SizedBox(height: 12),

                      // Tagline
                      Text(
                        'Where every moment becomes\na perfect memory',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Color(0xFF757575),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(delay: 600.ms, duration: 600.ms)
                          .slideY(
                              begin: 0.2,
                              end: 0,
                              delay: 600.ms,
                              duration: 600.ms),

                      const SizedBox(height: 20),

                      // Decorative element
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFE91C40).withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.favorite,
                              size: 16,
                              color: Color(0xFFE91C40).withOpacity(0.5),
                            ),
                          ),
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFE91C40).withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 800.ms, duration: 600.ms)
                          .scale(delay: 800.ms, duration: 600.ms),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // Middle Section - Email/Password Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_isLoading)
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                CircularProgressIndicator(
                                  color: Color(0xFFE91C40),
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _isSignUp
                                      ? 'Creating account...'
                                      : 'Signing you in...',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          // Header
                          Text(
                            _isSignUp ? 'Create Account' : 'Welcome Back',
                            style: GoogleFonts.lato(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E2E2E),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 1000.ms, duration: 500.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 1000.ms,
                                  duration: 500.ms),

                          const SizedBox(height: 8),

                          Text(
                            _isSignUp
                                ? 'Start planning amazing dates together'
                                : 'Sign in to continue your journey',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Color(0xFF9E9E9E),
                            ),
                          ).animate().fadeIn(delay: 1100.ms, duration: 500.ms),

                          const SizedBox(height: 40),

                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              hintText: 'your@email.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  color: Color(0xFFE91C40)),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Color(0xFFE91C40), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 1200.ms, duration: 500.ms)
                              .slideX(
                                  begin: -0.2,
                                  end: 0,
                                  delay: 1200.ms,
                                  duration: 500.ms),

                          const SizedBox(height: 20),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            validator: _isSignUp
                                ? _validatePassword
                                : (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Password is required';
                                    }
                                    return null;
                                  },
                            decoration: InputDecoration(
                              labelText: 'Password',
                              hintText: _isSignUp
                                  ? 'Min 8 chars, uppercase, number, special'
                                  : 'Enter password',
                              prefixIcon: Icon(Icons.lock_outline,
                                  color: Color(0xFFE91C40)),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF9E9E9E),
                                ),
                                onPressed: () {
                                  setState(() =>
                                      _obscurePassword = !_obscurePassword);
                                },
                              ),
                              filled: true,
                              fillColor: Color(0xFFF5F5F5),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide:
                                    BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(
                                    color: Color(0xFFE91C40), width: 2),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: Colors.red),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 1300.ms, duration: 500.ms)
                              .slideX(
                                  begin: -0.2,
                                  end: 0,
                                  delay: 1300.ms,
                                  duration: 500.ms),

                          // Forgot Password
                          if (!_isSignUp) ...[
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _resetPassword,
                                child: Text(
                                  'Forgot Password?',
                                  style: GoogleFonts.lato(
                                    color: Color(0xFFE91C40),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 1400.ms, duration: 500.ms),
                          ] else
                            const SizedBox(height: 20),

                          const SizedBox(height: 12),

                          // Sign In/Up Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: _handleAuth,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFE91C40),
                                      Color(0xFFFF6B9D)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    _isSignUp ? 'Create Account' : 'Sign In',
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 1500.ms, duration: 500.ms)
                              .slideY(
                                  begin: 0.2,
                                  end: 0,
                                  delay: 1500.ms,
                                  duration: 500.ms),

                          const SizedBox(height: 24),

                          // Toggle Sign In/Up
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isSignUp
                                    ? 'Already have an account?'
                                    : "Don't have an account?",
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: Color(0xFF757575),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _isSignUp = !_isSignUp);
                                  _formKey.currentState?.reset();
                                },
                                child: Text(
                                  _isSignUp ? 'Sign In' : 'Sign Up',
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFE91C40),
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 1600.ms, duration: 500.ms),

                          // Google Sign In (Android only, not iOS or web)
                          if (!kIsWeb && Platform.isAndroid && !_isSignUp) ...[
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                    child: Divider(color: Color(0xFFE0E0E0))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: GoogleFonts.lato(
                                      fontSize: 12,
                                      color: Color(0xFF9E9E9E),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Divider(color: Color(0xFFE0E0E0))),
                              ],
                            )
                                .animate()
                                .fadeIn(delay: 1700.ms, duration: 500.ms),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton(
                                onPressed:
                                    _isLoading ? null : _signInWithGoogle,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Color(0xFFE0E0E0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.g_mobiledata_rounded,
                                      size: 28,
                                      color: Color(0xFFE91C40),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continue with Google',
                                      style: GoogleFonts.lato(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF2E2E2E),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(delay: 1800.ms, duration: 500.ms)
                                .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    delay: 1800.ms,
                                    duration: 500.ms),
                          ],
                        ],
                      ],
                    ),
                  ),

                  // Bottom Section - Terms
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32, top: 40),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Icon(
                                Icons.lock_outline,
                                size: 16,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            Expanded(child: Divider(color: Color(0xFFE0E0E0))),
                          ],
                        ).animate().fadeIn(delay: 1400.ms, duration: 500.ms),
                        const SizedBox(height: 16),
                        Text(
                          'By continuing, you agree to our',
                          style: GoogleFonts.lato(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 1500.ms, duration: 500.ms),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: _openTermsOfService,
                              child: Text(
                                'Terms of Service',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Color(0xFFE91C40),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Text(
                              ' and ',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Color(0xFF9E9E9E),
                              ),
                            ),
                            GestureDetector(
                              onTap: _openPrivacyPolicy,
                              child: Text(
                                'Privacy Policy',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Color(0xFFE91C40),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 1600.ms, duration: 500.ms),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
