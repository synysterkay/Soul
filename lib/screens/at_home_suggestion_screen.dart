import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soul_plan/services/deepseek_service.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:ui';
import 'package:flutter_animate/flutter_animate.dart';

class AtHomeSuggestionScreen extends StatefulWidget {
  final String suggestion;

  const AtHomeSuggestionScreen({Key? key, required this.suggestion})
      : super(key: key);

  @override
  _AtHomeSuggestionScreenState createState() => _AtHomeSuggestionScreenState();
}

class _AtHomeSuggestionScreenState extends State<AtHomeSuggestionScreen> {
  final DeepSeekService _deepseekService = DeepSeekService();
  String _advice = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdvice();
  }

  Future<void> _loadAdvice() async {
    try {
      final advice =
          await _deepseekService.getAtHomeDateAdvice(widget.suggestion, 'en');
      setState(() {
        _advice = advice;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _advice = 'Failed to load advice. Please try again.';
        _isLoading = false;
      });
    }
  }

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
          'At-Home Date Idea',
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFE91C40)))
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                widget.suggestion,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E2E2E),
                ),
                textAlign: TextAlign.center,
              ),
            ).animate().fadeIn(delay: 100.ms).slideY(),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(20),
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
              child: _buildFormattedAdvice(),
            ),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildFormattedAdvice() {
    final parts = _advice.split('\n');
    if (parts.isEmpty) return SizedBox.shrink();

    final sectionTitles = [
      'Introduction',
      'Step-by-step guide',
      'Accommodation',
      'Special touches',
      'Conversation tips',
      'Preparation',
      'Adaptation',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part.trim().isEmpty) return SizedBox(height: 16);

        if (sectionTitles.any((title) =>
            part.trim().toLowerCase().startsWith(title.toLowerCase()))) {
          return Column(
            children: [
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFFE91C40).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  part.trim(),
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE91C40),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: 16),
            ],
          ).animate().fadeIn(delay: 200.ms);
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Text(
            part.trim(),
            style: GoogleFonts.lato(
              fontSize: 16,
              color: Color(0xFF2E2E2E),
              height: 1.5,
            ),
          ),
        ).animate().fadeIn(delay: 300.ms);
      }).toList(),
    );
  }
}
