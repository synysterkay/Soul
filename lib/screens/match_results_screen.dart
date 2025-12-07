import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/date_request_model.dart';
import '../services/deepseek_service.dart';
import '../services/date_request_service.dart';
import 'time_negotiation_screen.dart';

class MatchResultsScreen extends StatefulWidget {
  final String dateRequestId;

  const MatchResultsScreen({
    super.key,
    required this.dateRequestId,
  });

  @override
  State<MatchResultsScreen> createState() => _MatchResultsScreenState();
}

class _MatchResultsScreenState extends State<MatchResultsScreen> {
  bool _isLoading = true;
  bool _isMatching = false;
  Map<String, dynamic>? _matchResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performMatching();
  }

  Future<void> _performMatching() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doc = await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .get();

      if (!doc.exists) {
        throw Exception('Date request not found');
      }

      final data = doc.data()!;
      final dateRequest = DateRequestModel.fromFirestore(doc);

      // Check if already matched
      if (dateRequest.selectedDate != null) {
        setState(() {
          _matchResult = {
            'matchType': data['matchType'] ?? 'unknown',
            'date': dateRequest.selectedDate,
            'reasoning':
                data['matchReasoning'] ?? 'Your date has been matched!',
          };
          _isLoading = false;
        });
        return;
      }

      // Perform matching
      final deepSeekService =
          Provider.of<DeepSeekService>(context, listen: false);
      final dateRequestService =
          Provider.of<DateRequestService>(context, listen: false);

      final initiatorFavorites = dateRequest.initiatorFavorites ?? [];
      final partnerFavorites = dateRequest.partnerFavorites ?? [];
      final location = dateRequest.location ?? 'Unknown location';

      if (initiatorFavorites.isEmpty || partnerFavorites.isEmpty) {
        throw Exception('Both partners must select favorites before matching');
      }

      setState(() => _isMatching = true);

      // Call AI to match
      final result = await deepSeekService.matchDateSuggestions(
        initiatorFavorites: initiatorFavorites,
        partnerFavorites: partnerFavorites,
        location: location,
      );

      // Save the matched date
      await dateRequestService.saveMatchedDate(
        widget.dateRequestId,
        result['date'],
        result['matchType'],
        result['reasoning'],
      );

      if (!mounted) return;

      setState(() {
        _matchResult = result;
        _isLoading = false;
        _isMatching = false;
      });
    } catch (e) {
      print('Error performing matching: $e');
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isMatching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _isMatching) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B4CE6), Color(0xFF9D4EDD)],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    strokeWidth: 6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Finding Your Perfect Match...',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48),
                  child: Text(
                    'Our AI is analyzing both of your preferences to create the perfect date experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Match Results'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Oops! Something went wrong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _performMatching,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_matchResult == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match Results')),
        body: const Center(child: Text('No match result available')),
      );
    }

    final matchType = _matchResult!['matchType'] as String;
    final date = _matchResult!['date'] as Map<String, dynamic>;
    final reasoning = _matchResult!['reasoning'] as String;
    final isPerfectMatch = matchType == 'perfect';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                isPerfectMatch ? '🎉 Perfect Match!' : '✨ Your Matched Date',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6B4CE6), Color(0xFF9D4EDD)],
                  ),
                ),
                child: isPerfectMatch
                    ? const Center(
                        child: Icon(
                          Icons.favorite,
                          size: 80,
                          color: Colors.white70,
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.auto_awesome,
                          size: 80,
                          color: Colors.white70,
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Match type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPerfectMatch
                            ? [Colors.pink, Colors.red]
                            : [
                                const Color(0xFF6B4CE6),
                                const Color(0xFF9D4EDD)
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPerfectMatch ? Icons.favorite : Icons.auto_awesome,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isPerfectMatch ? 'Perfect Match' : 'AI Compromise',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date title
                  Text(
                    date['title'] ?? 'Matched Date',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reasoning card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Why This Date?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                reasoning,
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (date['description'] != null) ...[
                    Text(
                      date['description'],
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Activities
                  if (date['activities'] != null) ...[
                    _buildInfoCard(
                      icon: Icons.local_activity,
                      title: 'Activities',
                      content: (date['activities'] as List).join('\n• '),
                      iconColor: Colors.purple,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Venue
                  if (date['venue'] != null) ...[
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Venue',
                      content: date['venue'],
                      iconColor: Colors.red,
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Cost & Duration
                  Row(
                    children: [
                      if (date['estimatedCost'] != null)
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.attach_money,
                            title: 'Cost',
                            content: date['estimatedCost'],
                            iconColor: Colors.green,
                          ),
                        ),
                      if (date['estimatedCost'] != null &&
                          date['duration'] != null)
                        const SizedBox(width: 16),
                      if (date['duration'] != null)
                        Expanded(
                          child: _buildInfoCard(
                            icon: Icons.access_time,
                            title: 'Duration',
                            content: date['duration'],
                            iconColor: Colors.orange,
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to TimeNegotiationScreen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TimeNegotiationScreen(
                              dateRequestId: widget.dateRequestId,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6B4CE6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Love It! Let\'s Pick a Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
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
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
