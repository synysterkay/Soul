import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soul_plan/models/questionnaire.dart';
import 'package:soul_plan/services/date_request_service.dart';
import 'package:soul_plan/services/deepseek_service.dart';
import 'package:soul_plan/screens/intermediate_screen.dart';
import 'package:soul_plan/screens/favorites_selection_screen.dart';
import 'package:soul_plan/models/date_request_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String? dateRequestId;
  final String? mode;
  
  const QuestionnaireScreen({Key? key, this.dateRequestId, this.mode}) : super(key: key);
  
  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen>
    with SingleTickerProviderStateMixin {
  final Questionnaire _userQuestionnaire = Questionnaire();
  final Questionnaire _partnerQuestionnaire = Questionnaire();
  bool _isUserQuestionnaire = true;
  late AnimationController _animationController;
  Key _animatedTextKey = UniqueKey();
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E2E2E)),
          onPressed: () => Navigator.pop(context),
        ).animate().fadeIn(delay: 200.ms),
        title: Text(
          _isUserQuestionnaire
              ? 'Your Questionnaire'
              : 'Partner\'s Questionnaire',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: _buildQuestionnaireBody(),
    );
  }

  Widget _buildProgressIndicator() {
    final currentQuestionnaire =
        _isUserQuestionnaire ? _userQuestionnaire : _partnerQuestionnaire;
    final progress = currentQuestionnaire.progress;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question ${currentQuestionnaire.currentQuestionIndex + 1}',
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E2E2E),
              ),
            ),
            AnimatedCounter(
              value: (progress * 100).toInt(),
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE91C40),
              ),
            ),
          ],
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
        SizedBox(height: 8),
        TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: progress),
          duration: Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          builder: (context, double value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91C40)),
                minHeight: 8,
              ),
            );
          },
        ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildQuestionCard(Questionnaire questionnaire) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle(
            style: GoogleFonts.lato(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2E2E2E),
            ),
            child: AnimatedTextKit(
              key: _animatedTextKey,
              animatedTexts: [
                TypewriterAnimatedText(
                  questionnaire.currentQuestion.question,
                  speed: Duration(milliseconds: 50),
                  curve: Curves.easeOut,
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(
          begin: -0.2,
          end: 0,
          duration: 600.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildAnswerOptions(Questionnaire questionnaire) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: questionnaire.currentQuestion.options.length,
        itemBuilder: (context, index) {
          return _buildAnswerCard(
            questionnaire.currentQuestion.options[index],
            () {
              HapticFeedback.lightImpact();
              questionnaire.answerCurrentQuestion(
                questionnaire.currentQuestion.options[index],
              );
              _handleQuestionChange();
            },
            index,
          );
        },
      ),
    );
  }

  Widget _buildAnswerCard(String answer, VoidCallback onTap, int index) {
    return _buildGestureDetector(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              answer,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      onTap,
    ).animate().fadeIn(delay: (100 * index).ms).slideY(
          begin: 0.2,
          end: 0,
          curve: Curves.easeOutCubic,
          duration: 600.ms,
        );
  }

  Widget _buildQuestionnaireBody() {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgressIndicator(),
            SizedBox(height: 24),
            _buildQuestionCard(_isUserQuestionnaire
                ? _userQuestionnaire
                : _partnerQuestionnaire),
            SizedBox(height: 32),
            _buildAnswerOptions(_isUserQuestionnaire
                ? _userQuestionnaire
                : _partnerQuestionnaire),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureDetector(Widget child, VoidCallback onTap) {
    return GestureDetector(
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapCancel,
      onTap: onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: child,
      ),
    );
  }

  void _handleTapDown() {
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleQuestionChange() {
    _animationController.reverse().then((_) {
      setState(() {
        final currentQuestionnaire =
            _isUserQuestionnaire ? _userQuestionnaire : _partnerQuestionnaire;

        if (currentQuestionnaire.currentQuestionIndex ==
            currentQuestionnaire.questions.length - 1) {
          if (_isUserQuestionnaire) {
            _showIntermediateScreen();
          } else {
            _submitQuestionnaires();
          }
          return;
        }

        currentQuestionnaire.nextQuestion();
        _animatedTextKey = UniqueKey();
      });
      _animationController.forward();
    });
  }

  void _showIntermediateScreen() {
    Navigator.push(
      context,
      CustomPageRoute(page: IntermediateScreen()),
    ).then((_) {
      setState(() {
        _isUserQuestionnaire = false;
        _animatedTextKey = UniqueKey();
      });
      _animationController.reset();
      _animationController.forward();
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userQuestionnaire.initializeQuestions(context);
    _partnerQuestionnaire.initializeQuestions(context);
    _startEntryAnimation();
  }

  void _startEntryAnimation() {
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _submitQuestionnaires() async {
    try {
      print('=== Starting questionnaire submission ===');

      // Get route arguments
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      final dateRequestId = args?['dateRequestId'] as String?;
      print('Date Request ID: $dateRequestId');

      if (dateRequestId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Missing date request ID')),
        );
        return;
      }

      // Get current user
      final currentUser = FirebaseAuth.instance.currentUser;
      print('Current User ID: ${currentUser?.uid}');

      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Not authenticated')),
        );
        return;
      }

      // Prepare both user and partner answers
      print('User questionnaire answers: ${_userQuestionnaire.answers}');
      print('Partner questionnaire answers: ${_partnerQuestionnaire.answers}');

      final initiatorAnswers = {
        'responses': _userQuestionnaire.answers,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final partnerAnswers = {
        'responses': _partnerQuestionnaire.answers,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to date request
      final dateRequestService = DateRequestService();

      print('Saving initiator answers...');
      await dateRequestService.updateInitiatorAnswers(
          dateRequestId, initiatorAnswers);
      print('Initiator answers saved successfully');

      print('Saving partner answers...');
      await dateRequestService.updatePartnerAnswers(
          dateRequestId, partnerAnswers);
      print('Partner answers saved successfully');

      // Get the date request to check mode
      print('Fetching date request document...');
      final dateRequestDoc = await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(dateRequestId)
          .get();

      print('Date request doc exists: ${dateRequestDoc.exists}');
      print('Date request data: ${dateRequestDoc.data()}');

      print('Parsing DateRequestModel from Firestore...');
      final dateRequest = DateRequestModel.fromFirestore(dateRequestDoc);
      print('Date request mode: ${dateRequest.mode}');

      // Update status to questionnaireFilled
      await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(dateRequestId)
          .update({
        'status': 'questionnaireFilled',
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // For collaborative mode, continue to AI suggestions and favorites
        if (dateRequest.mode == DateRequestMode.collaborative) {
          // Show loading while generating AI suggestions
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => _LoadingDialog(),
          );

          // Generate AI suggestions
          try {
            print('Starting AI suggestion generation...');

            // Use DeepSeekService to generate suggestions based on both questionnaires
            final deepSeekService = DeepSeekService();

            // Get language preference
            final prefs = await SharedPreferences.getInstance();
            final languageCode = prefs.getString('language_code') ?? 'en';
            print('Language code: $languageCode');

            print('Calling DeepSeek service...');
            final suggestions = await deepSeekService.getDateSuggestions(
              _userQuestionnaire,
              _partnerQuestionnaire,
              language: languageCode,
            );
            print('Received ${suggestions.length} suggestions from AI');

            // Convert suggestions to the format expected by Firebase
            print('Converting suggestions to Firebase format...');
            final now = DateTime.now();
            final suggestionsData = suggestions.map((suggestion) {
              final title = suggestion
                  .split('\n')[0]
                  .replaceAll(RegExp(r'[*#\(\)\[\]]'), '')
                  .trim();
              print('Processing suggestion: $title');
              return {
                'title': title,
                'description': suggestion,
                'timestamp': Timestamp.fromDate(now),
              };
            }).toList();
            print('Converted ${suggestionsData.length} suggestions');

            // Save suggestions to Firebase
            print('Saving suggestions to Firebase...');
            await dateRequestService.saveSuggestions(
              dateRequestId,
              suggestionsData,
            );
            print('Suggestions saved successfully');

            if (mounted) {
              Navigator.pop(context); // Close loading dialog

              // Navigate to favorites selection
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesSelectionScreen(
                    dateRequestId: dateRequestId,
                  ),
                ),
              );
            }
          } catch (e, stackTrace) {
            print('!!! ERROR generating suggestions !!!');
            print('Error: $e');
            print('Stack trace: $stackTrace');
            if (mounted) {
              // Safely close loading dialog if it exists
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('Error generating suggestions: ${e.toString()}'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          }
        } else {
          // For other modes, navigate back to main screen
          Navigator.of(context).popUntil((route) => route.isFirst);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Questionnaires submitted successfully! 🎉'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('!!! FATAL ERROR submitting questionnaire !!!');
      print('Error: $e');
      print('Error type: ${e.runtimeType}');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting questionnaire: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;

  CustomPageRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
          transitionDuration: Duration(milliseconds: 500),
        );
}

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle style;

  const AnimatedCounter({
    required this.value,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: IntTween(begin: 0, end: value),
      duration: Duration(milliseconds: 800),
      builder: (context, int value, child) {
        return Text(
          '$value%',
          style: style,
        );
      },
    );
  }
}

class _LoadingDialog extends StatefulWidget {
  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<_LoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentStep = 0;
  final List<String> _steps = [
    'Analyzing your preferences...',
    'Finding perfect matches...',
    'Creating unique experiences...',
    'Almost there...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat();

    // Cycle through steps
    _cycleSteps();
  }

  void _cycleSteps() {
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % _steps.length;
        });
        _cycleSteps();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 40),
        padding: EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animated charging icon
            RotationTransition(
              turns: _controller,
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Color(0xFFE91C40),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Generating Date Ideas',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: Text(
                _steps[_currentStep],
                key: ValueKey<int>(_currentStep),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            // Progress indicator
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              child: const LinearProgressIndicator(
                minHeight: 6,
                backgroundColor: Color(0xFFF5F5F5),
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91C40)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
