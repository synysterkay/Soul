import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/invitation_service.dart';
import '../models/user_model.dart';

class PartnerDiscoveryScreen extends StatefulWidget {
  const PartnerDiscoveryScreen({super.key});

  @override
  State<PartnerDiscoveryScreen> createState() => _PartnerDiscoveryScreenState();
}

class _PartnerDiscoveryScreenState extends State<PartnerDiscoveryScreen> {
  bool _isLoadingContacts = false;
  List<Contact> _contacts = [];
  List<UserModel> _appUsers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoadingContacts = true);

    try {
      // Request contacts permission
      final status = await Permission.contacts.request();

      if (status.isGranted) {
        // Get all contacts with phone numbers
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _contacts = contacts;
        });

        // Extract phone numbers
        final List<String> phoneNumbers = [];
        for (final contact in _contacts) {
          if (contact.phones.isNotEmpty) {
            for (final phone in contact.phones) {
              // Clean phone number (remove spaces, dashes, etc.)
              final cleaned = phone.number.replaceAll(RegExp(r'[^\d+]'), '');
              phoneNumbers.add(cleaned);
            }
          }
        }

        // Find users in app with these phone numbers
        if (phoneNumbers.isNotEmpty && mounted) {
          final authService = context.read<AuthService>();
          final users = await authService.findUsersByPhoneNumbers(phoneNumbers);
          setState(() {
            _appUsers = users;
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contacts permission is required to find partners'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading contacts: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingContacts = false);
      }
    }
  }

  Future<void> _sendInvitation(UserModel user) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      final invitationService = InvitationService();

      await invitationService.sendInAppInvitation(
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Someone',
        senderPhotoURL: currentUser.photoURL,
        recipientId: user.uid,
        message: 'Let\'s plan amazing dates together!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invitation sent to ${user.displayName}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _inviteViaPhone(String phoneNumber) async {
    try {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;

      if (currentUser == null) {
        throw Exception('Not authenticated');
      }

      final invitationService = InvitationService();

      await invitationService.sendSmsInvitation(
        senderId: currentUser.uid,
        senderName: currentUser.displayName ?? 'Someone',
        senderPhotoURL: currentUser.photoURL,
        recipientPhone: phoneNumber,
        message: 'Join me on Soul Plan to plan amazing dates together!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMS invitation sent to $phoneNumber'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending SMS invitation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredAppUsers = _appUsers.where((user) {
      final searchLower = _searchController.text.toLowerCase();
      return (user.displayName?.toLowerCase().contains(searchLower) ?? false) ||
          (user.email.toLowerCase().contains(searchLower)) ||
          (user.phoneNumber?.contains(searchLower) ?? false);
    }).toList();

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
          'Find Partners',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Color(0xFF2E2E2E)),
                decoration: InputDecoration(
                  hintText: 'Search contacts...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9E9E9E),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Color(0xFFE91C40),
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Color(0xFFE91C40), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoadingContacts
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91C40),
                      ),
                    )
                  : _appUsers.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Color(0xFFE0E0E0),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No Partners Found',
                                  style: GoogleFonts.lato(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E2E2E),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'None of your contacts are using Soul Plan yet. Invite them to join!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Color(0xFF757575),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredAppUsers.length,
                          itemBuilder: (context, index) {
                            final user = filteredAppUsers[index];
                            return _UserCard(
                              user: user,
                              onInvite: () => _sendInvitation(user),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final UserModel user;
  final VoidCallback onInvite;

  const _UserCard({
    required this.user,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                user.photoURL != null ? NetworkImage(user.photoURL!) : null,
            child: user.photoURL == null
                ? Icon(Icons.person, color: Colors.white, size: 30)
                : null,
            backgroundColor: Color(0xFFE91C40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName ?? 'User',
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.phoneNumber ?? user.email,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onInvite,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFE91C40),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              elevation: 0,
            ),
            child: Text(
              'Invite',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
