import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/date_request_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/date_request_service.dart';
import 'location_selection_screen.dart';

class DateModeSelectionScreen extends StatefulWidget {
  final UserModel partner;

  const DateModeSelectionScreen({
    Key? key,
    required this.partner,
  }) : super(key: key);

  @override
  State<DateModeSelectionScreen> createState() =>
      _DateModeSelectionScreenState();
}

class _DateModeSelectionScreenState extends State<DateModeSelectionScreen> {
  DateRequestMode? _selectedMode;
  bool _isCreating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Plan a Date with ${widget.partner.displayName}',
                            style: GoogleFonts.raleway(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Choose how you want to plan your date',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Mode Cards
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    _ModeCard(
                      mode: DateRequestMode.collaborative,
                      title: 'Collaborative',
                      description:
                          'Work together! Both answer questions and pick favorites from AI suggestions.',
                      icon: Icons.people,
                      color: Colors.blue,
                      isSelected:
                          _selectedMode == DateRequestMode.collaborative,
                      onTap: () => setState(
                          () => _selectedMode = DateRequestMode.collaborative),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      mode: DateRequestMode.surprise,
                      title: 'Surprise',
                      description:
                          'Plan a surprise! You answer questions alone and pick the perfect date.',
                      icon: Icons.card_giftcard,
                      color: Colors.pink,
                      isSelected: _selectedMode == DateRequestMode.surprise,
                      onTap: () => setState(
                          () => _selectedMode = DateRequestMode.surprise),
                    ),
                    const SizedBox(height: 16),
                    _ModeCard(
                      mode: DateRequestMode.lastMinute,
                      title: 'Last Minute',
                      description:
                          'Quick date! Answer fewer questions and get fast suggestions.',
                      icon: Icons.flash_on,
                      color: Colors.orange,
                      isSelected: _selectedMode == DateRequestMode.lastMinute,
                      onTap: () => setState(
                          () => _selectedMode = DateRequestMode.lastMinute),
                    ),
                  ],
                ),
              ),

              // Continue Button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedMode == null || _isCreating
                        ? null
                        : _createDateRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6B4CE6),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: _isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(Color(0xFF6B4CE6)),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createDateRequest() async {
    if (_selectedMode == null) return;

    setState(() => _isCreating = true);

    try {
      // First, navigate to location selection
      final locationData = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LocationSelectionScreen(),
        ),
      );

      if (locationData == null || !mounted) {
        setState(() => _isCreating = false);
        return;
      }

      final authService = context.read<AuthService>();
      final dateRequestService = DateRequestService();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      // Create date request with location
      final dateRequest = await dateRequestService.createDateRequest(
        initiatorId: currentUser.uid,
        partnerId: widget.partner.uid,
        mode: _selectedMode!,
        location: locationData['location'],
        locationCoords: locationData['coordinates'],
      );

      if (mounted) {
        // Navigate to questionnaire screen
        Navigator.pushReplacementNamed(
          context,
          '/questionnaire',
          arguments: {
            'dateRequestId': dateRequest.id,
            'mode': _selectedMode,
            'partner': widget.partner,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating date request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }
}

class _ModeCard extends StatelessWidget {
  final DateRequestMode mode;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.raleway(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D3142),
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: color,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: GoogleFonts.raleway(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
