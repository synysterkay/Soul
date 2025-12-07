import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LoadingScreen extends StatefulWidget {
  final String suggestion;
  final String priceRange;
  final String city;

  const LoadingScreen({
    Key? key,
    required this.suggestion,
    required this.priceRange,
    required this.city,
  }) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _messageIndex = 0;
  late List<String> _messages;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeMessages();
  }

  void _initializeAnimation() {
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  void _initializeMessages() {
    if (mounted) {
      Future.delayed(Duration(seconds: 3), _changeMessage);
    }
  }

  List<String> _getMessages() {
    return [
      "Creating magical moments just for you...",
      "Exploring romantic spots in ${widget.city}...",
      "Crafting the perfect ${widget.suggestion} experience...",
      "Finding amazing dates within ${widget.priceRange}..."
    ];
  }

  Future<void> _changeMessage() async {
    if (mounted) {
      setState(() => _messageIndex = (_messageIndex + 1) % _messages.length);
      Future.delayed(Duration(seconds: 3), _changeMessage);
    }
  }

  void _handleBack() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _messages = _getMessages();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E2E2E)),
          onPressed: _handleBack,
        ).animate().fadeIn(delay: 200.ms),
        title: Text(
          "Planning Your Perfect Date",
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
      body: SafeArea(
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(30),
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
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _animation,
                  child: Icon(
                    Icons.favorite,
                    size: 100,
                    color: Color(0xFFE91C40),
                  ),
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: 30),
                Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(3),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91C40)),
                    strokeWidth: 3,
                  ),
                ).animate().fadeIn(delay: 400.ms),
                SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: Duration(milliseconds: 500),
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey<int>(_messageIndex),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2E2E2E),
                      height: 1.5,
                    ),
                  ).animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
