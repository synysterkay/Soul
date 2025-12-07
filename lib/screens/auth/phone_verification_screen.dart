import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../post_signin_onboarding_screen.dart';

class PhoneVerificationScreen extends StatefulWidget {
  final bool isInitialSignIn;

  const PhoneVerificationScreen({
    super.key,
    this.isInitialSignIn = false,
  });

  @override
  State<PhoneVerificationScreen> createState() =>
      _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedCountryCode = '+1';
  String? _verificationId;
  bool _codeSent = false;
  bool _isLoading = false;

  final List<Map<String, String>> _countryCodes = [
    {'code': '+1', 'country': 'US/CA'},
    {'code': '+44', 'country': 'UK'},
    {'code': '+33', 'country': 'FR'},
    {'code': '+49', 'country': 'DE'},
    {'code': '+91', 'country': 'IN'},
    {'code': '+86', 'country': 'CN'},
    {'code': '+81', 'country': 'JP'},
    {'code': '+82', 'country': 'KR'},
    {'code': '+61', 'country': 'AU'},
    {'code': '+55', 'country': 'BR'},
    {'code': '+52', 'country': 'MX'},
    {'code': '+34', 'country': 'ES'},
    {'code': '+39', 'country': 'IT'},
    {'code': '+7', 'country': 'RU'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
    final authService = context.read<AuthService>();

    try {
      await authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        codeSent: (verificationId) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _codeSent = true;
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Verification code sent!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        verificationFailed: (error) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Verification failed: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        verificationCompleted: (credential) async {
          // Auto-verification (Android only)
          if (mounted) {
            await _signInWithCredential(credential);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verifyCode() async {
    if (_verificationId == null || _codeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the verification code'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = context.read<AuthService>();

      if (widget.isInitialSignIn) {
        // Sign in with phone number
        await authService.signInWithPhoneNumber(
          verificationId: _verificationId!,
          smsCode: _codeController.text,
        );
      } else {
        // Link phone number to existing account
        final phoneNumber = '$_selectedCountryCode${_phoneController.text}';
        await authService.linkPhoneNumber(
          phoneNumber: phoneNumber,
          verificationId: _verificationId!,
          smsCode: _codeController.text,
        );
      }

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
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Verification failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    setState(() => _isLoading = true);

    try {
      if (widget.isInitialSignIn) {
        await FirebaseAuth.instance.signInWithCredential(credential);
      } else {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
      }

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
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF6B4CE6),
              const Color(0xFF9D4EDD),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Verify your phone',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _codeSent
                        ? 'Enter the code sent to your phone'
                        : 'We\'ll send you a verification code',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  if (!_codeSent) ...[
                    // Phone number input
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Country code dropdown
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            underline: const SizedBox(),
                            items: _countryCodes.map((country) {
                              return DropdownMenuItem(
                                value: country['code'],
                                child: Text(
                                  '${country['code']} ${country['country']}',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedCountryCode = value);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Phone number field
                        Expanded(
                          child: TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                              hintText: 'Phone number',
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.length < 7) {
                                return 'Invalid phone number';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Send code button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendVerificationCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6B4CE6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Send Code',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ] else ...[
                    // Verification code input
                    TextFormField(
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                      decoration: InputDecoration(
                        hintText: '------',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Verify button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF6B4CE6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Verify',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Resend code
                    Center(
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _codeSent = false;
                                  _codeController.clear();
                                });
                              },
                        child: const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
