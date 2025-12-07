import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/date_request_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/date_request_service.dart';
import 'favorites_selection_screen.dart';
import 'match_results_screen.dart';
import 'time_negotiation_screen.dart';
import 'questionnaire_screen.dart';

class DateRequestsListScreen extends StatelessWidget {
  const DateRequestsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(
        child: Text('Not authenticated'),
      );
    }

    return StreamBuilder<List<DateRequestModel>>(
      stream: DateRequestService().getDateRequests(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFE91C40),
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.raleway(
                color: Color(0xFF2E2E2E),
              ),
            ),
          );
        }

        final dateRequests = snapshot.data ?? [];

        if (dateRequests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF5F7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.calendar_today_outlined,
                    size: 60,
                    color: Color(0xFFE91C40),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No active date requests',
                  style: GoogleFonts.raleway(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Go to Home to start planning a date!',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: dateRequests.length,
          itemBuilder: (context, index) {
            return _DateRequestCard(
              dateRequest: dateRequests[index],
              userId: userId,
            );
          },
        );
      },
    );
  }
}

class _DateRequestCard extends StatelessWidget {
  final DateRequestModel dateRequest;
  final String userId;

  const _DateRequestCard({
    required this.dateRequest,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final isInitiator = dateRequest.initiatorId == userId;
    final partnerId =
        isInitiator ? dateRequest.partnerId : dateRequest.initiatorId;

    return FutureBuilder<UserModel?>(
      future: context.read<AuthService>().getUserData(partnerId),
      builder: (context, partnerSnapshot) {
        final partner = partnerSnapshot.data;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: () => _navigateToDateRequest(context),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Partner info & Mode badge
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: partner?.photoURL != null
                            ? NetworkImage(partner!.photoURL!)
                            : null,
                        child: partner?.photoURL == null
                            ? Text(
                                partner?.displayName?[0].toUpperCase() ?? '?',
                                style: const TextStyle(fontSize: 20),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date with ${partner?.displayName ?? "Partner"}',
                              style: GoogleFonts.raleway(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E2E),
                              ),
                            ),
                            Text(
                              isInitiator
                                  ? 'You initiated'
                                  : 'Partner initiated',
                              style: GoogleFonts.raleway(
                                fontSize: 14,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _ModeBadge(mode: dateRequest.mode),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status
                  _StatusIndicator(status: dateRequest.status),

                  const SizedBox(height: 12),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _navigateToDateRequest(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE91C40),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        _getActionText(),
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getActionText() {
    switch (dateRequest.status) {
      case DateRequestStatus.pending:
      case DateRequestStatus.questionnaireFilled:
        return 'Continue Questionnaire';
      case DateRequestStatus.suggestionsGenerated:
        return 'View Suggestions';
      case DateRequestStatus.selecting:
        return 'Select Favorites';
      case DateRequestStatus.matched:
        return 'View Match';
      case DateRequestStatus.timeNegotiating:
        return 'Confirm Time';
      case DateRequestStatus.confirmed:
        return 'View Date';
      case DateRequestStatus.completed:
        return 'View Details';
      case DateRequestStatus.cancelled:
        return 'View Details';
    }
  }

  void _navigateToDateRequest(BuildContext context) {
    // Navigate to appropriate screen based on status
    switch (dateRequest.status) {
      case DateRequestStatus.suggestionsGenerated:
      case DateRequestStatus.selecting:
        // Navigate to favorites selection
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FavoritesSelectionScreen(
              dateRequestId: dateRequest.id,
            ),
          ),
        );
        break;

      case DateRequestStatus.matched:
        // Navigate to match results
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchResultsScreen(
              dateRequestId: dateRequest.id,
            ),
          ),
        );
        break;

      case DateRequestStatus.timeNegotiating:
        // Navigate to time negotiation screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TimeNegotiationScreen(
              dateRequestId: dateRequest.id,
            ),
          ),
        );
        break;

      case DateRequestStatus.confirmed:
        // TODO: Navigate to confirmed date details when implemented
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Date confirmed! Details view coming soon.'),
          ),
        );
        break;

      case DateRequestStatus.pending:
      case DateRequestStatus.questionnaireFilled:
        // Navigate to questionnaire to continue/complete it
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionnaireScreen(
              dateRequestId: dateRequest.id,
              mode: dateRequest.mode.name,
            ),
          ),
        );
        break;

      default:
        // Show info for other statuses
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status: ${dateRequest.status.name}'),
          ),
        );
    }
  }
}

class _ModeBadge extends StatelessWidget {
  final DateRequestMode mode;

  const _ModeBadge({required this.mode});

  @override
  Widget build(BuildContext context) {
    final config = _getModeConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: config['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'],
            size: 16,
            color: config['color'],
          ),
          const SizedBox(width: 4),
          Text(
            config['label'],
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: config['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getModeConfig() {
    switch (mode) {
      case DateRequestMode.collaborative:
        return {
          'label': 'Collaborative',
          'icon': Icons.people,
          'color': Colors.blue,
        };
      case DateRequestMode.surprise:
        return {
          'label': 'Surprise',
          'icon': Icons.card_giftcard,
          'color': Colors.pink,
        };
      case DateRequestMode.lastMinute:
        return {
          'label': 'Last Minute',
          'icon': Icons.flash_on,
          'color': Colors.orange,
        };
    }
  }
}

class _StatusIndicator extends StatelessWidget {
  final DateRequestStatus status;

  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: _getStatusColor(),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            _getStatusText(),
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Color(0xFF757575),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (status) {
      case DateRequestStatus.pending:
        return 'Waiting for questionnaire';
      case DateRequestStatus.questionnaireFilled:
        return 'Questionnaire complete';
      case DateRequestStatus.suggestionsGenerated:
        return 'Review AI suggestions';
      case DateRequestStatus.selecting:
        return 'Selecting favorites';
      case DateRequestStatus.matched:
        return 'Perfect match found!';
      case DateRequestStatus.timeNegotiating:
        return 'Confirming date & time';
      case DateRequestStatus.confirmed:
        return 'Date confirmed!';
      case DateRequestStatus.completed:
        return 'Completed';
      case DateRequestStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getStatusColor() {
    switch (status) {
      case DateRequestStatus.pending:
      case DateRequestStatus.questionnaireFilled:
        return Colors.orange;
      case DateRequestStatus.suggestionsGenerated:
      case DateRequestStatus.selecting:
      case DateRequestStatus.matched:
        return Colors.blue;
      case DateRequestStatus.timeNegotiating:
        return Colors.purple;
      case DateRequestStatus.confirmed:
        return Colors.green;
      case DateRequestStatus.completed:
      case DateRequestStatus.cancelled:
        return Colors.grey;
    }
  }
}
