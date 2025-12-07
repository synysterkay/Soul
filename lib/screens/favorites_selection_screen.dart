import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/date_request_model.dart';
import '../services/date_request_service.dart';
import '../services/auth_service.dart';
import '../services/deepseek_service.dart';
import 'venue_selection_screen.dart';

class FavoritesSelectionScreen extends StatefulWidget {
  final String dateRequestId;

  const FavoritesSelectionScreen({
    super.key,
    required this.dateRequestId,
  });

  @override
  State<FavoritesSelectionScreen> createState() =>
      _FavoritesSelectionScreenState();
}

class _FavoritesSelectionScreenState extends State<FavoritesSelectionScreen> {
  // Map to store priority: index -> priority (1, 2, or 3)
  final Map<int, int> _priorities = {};
  bool _isSubmitting = false;
  // Track expanded cards
  final Set<int> _expandedCards = {};

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final dateRequestService =
        Provider.of<DateRequestService>(context, listen: false);
    final currentUserId = authService.currentUser?.uid;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text('Select Favorites')),
            body: const Center(child: Text('Date request not found')),
          );
        }

        final dateRequest = DateRequestModel.fromFirestore(snapshot.data!);

        // Check if user is initiator or partner
        final isInitiator = dateRequest.initiatorId == currentUserId;
        final isPartner = dateRequest.partnerId == currentUserId;

        // For "Complete Together" mode with temp partner, allow current user to submit for both
        final isTempPartner = dateRequest.partnerId.startsWith('temp_partner_');
        final isCollaborative =
            dateRequest.mode == DateRequestMode.collaborative;

        if (!isInitiator && !isPartner && !isTempPartner) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text(
                'Select Favorites',
                style: TextStyle(color: Color(0xFF2E2E2E)),
              ),
            ),
            body: const Center(child: Text('Access denied')),
          );
        }

        // Check if this user already submitted favorites
        final initiatorSubmitted = dateRequest.initiatorFavorites != null &&
            dateRequest.initiatorFavorites!.isNotEmpty;
        final partnerSubmitted = dateRequest.partnerFavorites != null &&
            dateRequest.partnerFavorites!.isNotEmpty;

        // For temp partner mode, check if BOTH have submitted
        final alreadySubmitted = isTempPartner && isCollaborative
            ? (initiatorSubmitted && partnerSubmitted)
            : (isInitiator ? initiatorSubmitted : partnerSubmitted);

        if (alreadySubmitted) {
          return Scaffold(
            appBar: AppBar(title: const Text('Favorites Selected')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'You\'ve already selected your favorites!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Waiting for your partner to select their favorites...',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Dates'),
                  ),
                ],
              ),
            ),
          );
        }

        final suggestions = dateRequest.suggestions ?? [];

        if (suggestions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Select Favorites')),
            body: const Center(
              child: Text('No suggestions available yet'),
            ),
          );
        }

        // For Complete Together mode, determine which role to submit as
        String selectionFor = 'your';
        if (isTempPartner && isCollaborative) {
          if (!initiatorSubmitted) {
            selectionFor = 'Person 1\'s';
          } else if (!partnerSubmitted) {
            selectionFor = 'Person 2\'s';
          }
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'Select $selectionFor Favorites',
              style: const TextStyle(
                color: Color(0xFF2E2E2E),
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // Header with selection summary
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF5F7),
                  border: Border(
                    bottom: BorderSide(
                      color: const Color(0xFFFFE4EA),
                      width: 1,
                    ),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Rank Your Top 3 Date Ideas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the buttons to mark your 1st, 2nd, and 3rd choice',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    _buildSelectionSummary(),
                  ],
                ),
              ),

              // Scrollable list of all suggestions
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: suggestions.length,
                  itemBuilder: (context, index) {
                    return _buildSuggestionCard(
                      suggestions[index],
                      index,
                    );
                  },
                ),
              ),

              // Submit button
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _priorities.length == 3 && !_isSubmitting
                          ? () => _submitFavorites(
                                dateRequestService,
                                dateRequest,
                                isTempPartner,
                                initiatorSubmitted,
                                partnerSubmitted,
                              )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91C40),
                        disabledBackgroundColor: const Color(0xFFE0E0E0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _priorities.length == 3
                                  ? 'Submit Favorites'
                                  : 'Select ${3 - _priorities.length} more',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _priorities.length == 3
                                    ? Colors.white
                                    : const Color(0xFF9E9E9E),
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSelectionSummary() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPriorityChip(1),
        const SizedBox(width: 12),
        _buildPriorityChip(2),
        const SizedBox(width: 12),
        _buildPriorityChip(3),
      ],
    );
  }

  Widget _buildPriorityChip(int priority) {
    // Find which index has this priority
    final index = _priorities.entries
        .firstWhere((e) => e.value == priority, orElse: () => const MapEntry(-1, 0))
        .key;
    
    final hasSelection = index != -1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: hasSelection ? const Color(0xFFE91C40) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasSelection ? const Color(0xFFE91C40) : const Color(0xFFE0E0E0),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: hasSelection ? Colors.white : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$priority',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: hasSelection ? const Color(0xFFE91C40) : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
          if (hasSelection) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.check,
              size: 16,
              color: Colors.white,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionCard(Map<String, dynamic> suggestion, int index) {
    final priority = _priorities[index]; // null if not selected
    final hasRank = priority != null;
    final isExpanded = _expandedCards.contains(index);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        border: Border.all(
          color: hasRank ? const Color(0xFFE91C40) : const Color(0xFFE0E0E0),
          width: hasRank ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Tappable to expand
          InkWell(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedCards.remove(index);
                } else {
                  _expandedCards.add(index);
                }
              });
            },
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: hasRank ? const Color(0xFFFFF5F7) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(15),
                  topRight: const Radius.circular(15),
                  bottomLeft: isExpanded ? Radius.zero : const Radius.circular(15),
                  bottomRight: isExpanded ? Radius.zero : const Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion['title'] ?? 'Untitled Date',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E2E2E),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isExpanded ? 'Tap to collapse' : 'Tap to read more',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasRank)
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE91C40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getPriorityLabel(priority).split(' ')[0], // Just "1st", "2nd", "3rd"
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFF9E9E9E),
                  ),
                ],
              ),
            ),
          ),

          // Expandable Content
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Full description
                  if (suggestion['description'] != null) ...[
                    Text(
                      suggestion['description'],
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF2E2E2E),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Detailed info sections
                  if (suggestion['activities'] != null) ...[
                    _buildDetailSection(
                      icon: Icons.celebration,
                      title: 'Activities',
                      content: (suggestion['activities'] as List).join(' • '),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (suggestion['venue'] != null) ...[
                    _buildDetailSection(
                      icon: Icons.location_on,
                      title: 'Venue',
                      content: suggestion['venue'],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (suggestion['duration'] != null) ...[
                    _buildDetailSection(
                      icon: Icons.schedule,
                      title: 'Duration',
                      content: suggestion['duration'],
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (suggestion['estimatedCost'] != null) ...[
                    _buildDetailSection(
                      icon: Icons.payments,
                      title: 'Estimated Cost',
                      content: suggestion['estimatedCost'],
                    ),
                    const SizedBox(height: 16),
                  ] else
                    const SizedBox(height: 4),

                  // Priority selection buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriorityButton(index, 1),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityButton(index, 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityButton(index, 3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Collapsed preview with priority buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brief preview
                  if (suggestion['description'] != null) ...[
                    Text(
                      suggestion['description'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF757575),
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  // Quick info chips
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      if (suggestion['duration'] != null)
                        _buildQuickInfo(Icons.schedule, suggestion['duration']),
                      if (suggestion['estimatedCost'] != null)
                        _buildQuickInfo(Icons.payments, suggestion['estimatedCost']),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Priority selection buttons
                  Row(
                    children: [
                      Expanded(
                        child: _buildPriorityButton(index, 1),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityButton(index, 2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildPriorityButton(index, 3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFFE91C40),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9E9E9E),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2E2E2E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9E9E9E)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9E9E9E),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButton(int index, int priority) {
    final currentPriority = _priorities[index];
    final isSelected = currentPriority == priority;
    final isPriorityTaken = _priorities.values.contains(priority) && !isSelected;

    return ElevatedButton(
      onPressed: isPriorityTaken ? null : () => _setPriority(index, priority),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? const Color(0xFFE91C40) : Colors.white,
        foregroundColor: isSelected ? Colors.white : const Color(0xFF2E2E2E),
        disabledBackgroundColor: const Color(0xFFF5F5F5),
        disabledForegroundColor: const Color(0xFFE0E0E0),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected
                ? const Color(0xFFE91C40)
                : isPriorityTaken
                    ? const Color(0xFFE0E0E0)
                    : const Color(0xFFE91C40),
            width: 2,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        _getPriorityLabel(priority),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isPriorityTaken
              ? const Color(0xFFE0E0E0)
              : isSelected
                  ? Colors.white
                  : const Color(0xFFE91C40),
        ),
      ),
    );
  }

  String _getPriorityLabel(int priority) {
    switch (priority) {
      case 1:
        return '1st Choice';
      case 2:
        return '2nd Choice';
      case 3:
        return '3rd Choice';
      default:
        return '';
    }
  }

  void _setPriority(int index, int priority) {
    setState(() {
      final currentPriority = _priorities[index];
      
      if (currentPriority == priority) {
        // Clicking the same priority again - remove it
        _priorities.remove(index);
      } else {
        // Set new priority
        _priorities[index] = priority;
      }
    });
  }



  Future<void> _submitFavorites(
    DateRequestService dateRequestService,
    DateRequestModel dateRequest,
    bool isTempPartner,
    bool initiatorSubmitted,
    bool partnerSubmitted,
  ) async {
    if (_priorities.length != 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select exactly 3 favorites'),
          backgroundColor: Color(0xFFE91C40),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Sort by priority (1st, 2nd, 3rd) to get the ordered list
      final sortedEntries = _priorities.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      final selectedSuggestions = sortedEntries
          .map((entry) => dateRequest.suggestions![entry.key])
          .toList();

      // For "Complete Together" mode with temp partner
      if (isTempPartner && dateRequest.mode == DateRequestMode.collaborative) {
        // If initiator hasn't submitted yet, submit for them first
        if (!initiatorSubmitted) {
          await dateRequestService.updateInitiatorFavorites(
            widget.dateRequestId,
            selectedSuggestions,
          );

          if (!mounted) return;

          // Clear selections and show message to select for partner
          setState(() {
            _priorities.clear();
            _isSubmitting = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Person 1 favorites saved! Now select for Person 2'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }

        // If initiator already submitted, submit for partner
        if (!partnerSubmitted) {
          await dateRequestService.updatePartnerFavorites(
            widget.dateRequestId,
            selectedSuggestions,
          );
        }
      } else {
        // Normal mode - submit for current user
        final currentUserId =
            Provider.of<AuthService>(context, listen: false).currentUser?.uid;
        final isInitiator = dateRequest.initiatorId == currentUserId;

        if (isInitiator) {
          await dateRequestService.updateInitiatorFavorites(
            widget.dateRequestId,
            selectedSuggestions,
          );
        } else {
          await dateRequestService.updatePartnerFavorites(
            widget.dateRequestId,
            selectedSuggestions,
          );
        }
      }

      if (!mounted) return;

      // Check if both partners have now submitted
      final updatedDoc = await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .get();
      final updatedRequest = DateRequestModel.fromFirestore(updatedDoc);

      final bothSubmitted = (updatedRequest.initiatorFavorites != null &&
              updatedRequest.initiatorFavorites!.isNotEmpty) &&
          (updatedRequest.partnerFavorites != null &&
              updatedRequest.partnerFavorites!.isNotEmpty);

      if (bothSubmitted) {
        // Both have submitted - show matching dialog and perform AI matching
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              _MatchingDialog(dateRequestId: widget.dateRequestId),
        );
      } else {
        // Only one submitted - go back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Favorites saved! Waiting for partner...'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting favorites: $e');
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving favorites: ${e.toString()}'),
          backgroundColor: const Color(0xFFE91C40),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Matching Dialog Widget
class _MatchingDialog extends StatefulWidget {
  final String dateRequestId;

  const _MatchingDialog({required this.dateRequestId});

  @override
  State<_MatchingDialog> createState() => _MatchingDialogState();
}

class _MatchingDialogState extends State<_MatchingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusMessage = 'Analyzing your favorites...';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _performMatching();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _performMatching() async {
    try {
      // Load date request
      final doc = await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .get();

      if (!doc.exists) throw Exception('Date request not found');

      final dateRequest = DateRequestModel.fromFirestore(doc);

      setState(() => _statusMessage = 'Finding common interests...');
      await Future.delayed(const Duration(milliseconds: 1500));

      // Perform AI matching
      final deepSeekService = DeepSeekService();
      final matchResult = await deepSeekService.matchDateSuggestions(
        initiatorFavorites: dateRequest.initiatorFavorites ?? [],
        partnerFavorites: dateRequest.partnerFavorites ?? [],
        location: dateRequest.location ?? 'Unknown',
      );

      setState(() => _statusMessage = 'Creating the perfect date...');
      await Future.delayed(const Duration(milliseconds: 1000));

      // Save matched date
      final dateRequestService = DateRequestService();
      await dateRequestService.saveMatchedDate(
        widget.dateRequestId,
        matchResult['date'],
        matchResult['matchType'],
        matchResult['reasoning'],
      );

      if (!mounted) return;

      setState(() => _statusMessage = 'Finding perfect venues...');
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to venue selection
      if (!mounted) return;
      Navigator.of(context).pop(); // Close dialog
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => VenueSelectionScreen(
            dateRequestId: widget.dateRequestId,
          ),
        ),
      );
    } catch (e) {
      print('Error performing matching: $e');
      if (!mounted) return;

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error matching dates: ${e.toString()}'),
          backgroundColor: const Color(0xFFE91C40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _controller,
              child: const Icon(
                Icons.favorite,
                size: 60,
                color: Color(0xFFE91C40),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Matching Your Favorites',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _statusMessage,
                key: ValueKey<String>(_statusMessage),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF757575),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
