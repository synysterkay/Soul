import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/invitation_model.dart';
import '../../services/auth_service.dart';
import '../../services/invitation_service.dart';

class InvitationsScreen extends StatelessWidget {
  const InvitationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(
          child: Text('Not authenticated'),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Invitations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Received'),
              Tab(text: 'Sent'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ReceivedInvitationsTab(userId: userId),
            _SentInvitationsTab(userId: userId),
          ],
        ),
      ),
    );
  }
}

class _ReceivedInvitationsTab extends StatelessWidget {
  final String userId;

  const _ReceivedInvitationsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    final invitationService = InvitationService();

    return StreamBuilder<List<InvitationModel>>(
      stream: invitationService.getPendingInvitations(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final invitations = snapshot.data ?? [];

        if (invitations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.mail_outline,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No pending invitations',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            return _InvitationCard(
              invitation: invitations[index],
              userId: userId,
            );
          },
        );
      },
    );
  }
}

class _SentInvitationsTab extends StatelessWidget {
  final String userId;

  const _SentInvitationsTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    final invitationService = InvitationService();

    return StreamBuilder<List<InvitationModel>>(
      stream: invitationService.getSentInvitations(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final invitations = snapshot.data ?? [];

        if (invitations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.send_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No sent invitations',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: invitations.length,
          itemBuilder: (context, index) {
            return _SentInvitationCard(
              invitation: invitations[index],
            );
          },
        );
      },
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final InvitationModel invitation;
  final String userId;

  const _InvitationCard({
    required this.invitation,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: invitation.senderPhotoURL != null
                      ? NetworkImage(invitation.senderPhotoURL!)
                      : null,
                  child: invitation.senderPhotoURL == null
                      ? Text(
                          invitation.senderName[0].toUpperCase(),
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invitation.senderName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Wants to be your partner',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (invitation.message != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invitation.message!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptInvitation(context),
                    icon: const Icon(Icons.check),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _declineInvitation(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptInvitation(BuildContext context) async {
    try {
      final invitationService = InvitationService();
      final invitationId = invitation.metadata?['invitationId'] as String?;

      if (invitationId == null) {
        throw Exception('Invitation ID not found');
      }

      await invitationService.acceptInvitation(invitationId, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('You are now partners with ${invitation.senderName}!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _declineInvitation(BuildContext context) async {
    try {
      final invitationService = InvitationService();
      final invitationId = invitation.metadata?['invitationId'] as String?;

      if (invitationId == null) {
        throw Exception('Invitation ID not found');
      }

      await invitationService.declineInvitation(invitationId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation declined'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error declining invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SentInvitationCard extends StatelessWidget {
  final InvitationModel invitation;

  const _SentInvitationCard({
    required this.invitation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRecipientDisplay(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getStatusText(),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getStatusColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: invitation.status),
              ],
            ),
            if (invitation.status == InvitationStatus.pending) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _cancelInvitation(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Cancel'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getRecipientDisplay() {
    if (invitation.recipientPhone != null) {
      return invitation.recipientPhone!;
    } else if (invitation.recipientEmail != null) {
      return invitation.recipientEmail!;
    } else {
      return invitation.recipientId ?? 'Unknown';
    }
  }

  String _getStatusText() {
    switch (invitation.status) {
      case InvitationStatus.pending:
        return 'Waiting for response';
      case InvitationStatus.sent:
        return 'Sent';
      case InvitationStatus.accepted:
        return 'Accepted';
      case InvitationStatus.declined:
        return 'Declined';
      case InvitationStatus.expired:
        return 'Expired';
    }
  }

  Color _getStatusColor() {
    switch (invitation.status) {
      case InvitationStatus.pending:
      case InvitationStatus.sent:
        return Colors.orange;
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.declined:
      case InvitationStatus.expired:
        return Colors.grey;
    }
  }

  Future<void> _cancelInvitation(BuildContext context) async {
    try {
      final invitationService = InvitationService();
      final invitationId = invitation.metadata?['invitationId'] as String?;

      if (invitationId == null) {
        throw Exception('Invitation ID not found');
      }

      await invitationService.cancelInvitation(invitationId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation cancelled'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final InvitationStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: _getTextColor(),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getLabel() {
    switch (status) {
      case InvitationStatus.pending:
        return 'PENDING';
      case InvitationStatus.sent:
        return 'SENT';
      case InvitationStatus.accepted:
        return 'ACCEPTED';
      case InvitationStatus.declined:
        return 'DECLINED';
      case InvitationStatus.expired:
        return 'EXPIRED';
    }
  }

  Color _getBackgroundColor() {
    switch (status) {
      case InvitationStatus.pending:
      case InvitationStatus.sent:
        return Colors.orange[100]!;
      case InvitationStatus.accepted:
        return Colors.green[100]!;
      case InvitationStatus.declined:
      case InvitationStatus.expired:
        return Colors.grey[200]!;
    }
  }

  Color _getTextColor() {
    switch (status) {
      case InvitationStatus.pending:
      case InvitationStatus.sent:
        return Colors.orange[900]!;
      case InvitationStatus.accepted:
        return Colors.green[900]!;
      case InvitationStatus.declined:
      case InvitationStatus.expired:
        return Colors.grey[700]!;
    }
  }
}
