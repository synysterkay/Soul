import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/auth_service.dart';
import '../services/invitation_service.dart';
import '../models/user_model.dart';
import 'partner_discovery_screen.dart';
import 'invitations/invitations_screen.dart';
import 'date_requests_list_screen.dart';
import 'date_mode_selection_screen.dart';
import 'profile_completion_screen.dart';
import 'questionnaire_flow_screen.dart';

class MainScreen extends StatefulWidget {
  final int? initialTab;
  final String? initialDateRequestId;
  
  const MainScreen({super.key, this.initialTab, this.initialDateRequestId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    final authService = context.read<AuthService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            _HomeTab(user: user, authService: authService),
            _DateRequestsTab(),
            _PartnersTab(),
            _ProfileTab(user: user, authService: authService),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.1 * 255).round()),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavBarItem(
                  icon: Icons.home,
                  label: 'Home',
                  isSelected: _selectedIndex == 0,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                _NavBarItem(
                  icon: Icons.calendar_today,
                  label: 'Dates',
                  isSelected: _selectedIndex == 1,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                _NavBarItem(
                  icon: Icons.people,
                  label: 'Partners',
                  isSelected: _selectedIndex == 2,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                _NavBarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isSelected: _selectedIndex == 3,
                  onTap: () => setState(() => _selectedIndex = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6B4CE6).withAlpha((0.1 * 255).round())
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFE91C40) : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFFE91C40) : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final User? user;
  final AuthService authService;

  const _HomeTab({required this.user, required this.authService});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with invitations badge
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, color: Color(0xFFE91C40))
                    : null,
                backgroundColor: Color(0xFFFFF5F7),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: Color(0xFF757575),
                      ),
                    ),
                    Text(
                      user?.displayName ?? 'User',
                      style: GoogleFonts.raleway(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ],
                ),
              ),
              // Invitations button
              StreamBuilder<List<dynamic>>(
                stream: user?.uid != null
                    ? InvitationService().getPendingInvitations(user!.uid)
                    : null,
                builder: (context, snapshot) {
                  final pendingCount = snapshot.data?.length ?? 0;

                  return Stack(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InvitationsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.mail_outline,
                          color: Color(0xFFE91C40),
                          size: 28,
                        ),
                      ),
                      if (pendingCount > 0)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$pendingCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Main CTA Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.1 * 255).round()),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF5F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.favorite,
                    size: 40,
                    color: const Color(0xFFE91C40),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Plan Your Perfect Date',
                  style: GoogleFonts.raleway(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let AI help you create amazing experiences with your partner',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Check if profile is complete
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        final userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();

                        final isProfileComplete =
                            userDoc.data()?['isProfileComplete'] ?? false;

                        if (!isProfileComplete && context.mounted) {
                          // Navigate to profile completion
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const ProfileCompletionScreen(),
                            ),
                          );

                          // If profile completed, continue to questionnaire flow
                          if (result == true && context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const QuestionnaireFlowScreen(),
                              ),
                            );
                          }
                        } else if (context.mounted) {
                          // Profile already complete, go to questionnaire flow
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const QuestionnaireFlowScreen(),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91C40),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                      shadowColor: Color(0xFFE91C40).withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Start Planning',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Features Section
          Text(
            'How It Works',
            style: GoogleFonts.raleway(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            icon: Icons.people_outline,
            title: 'Invite Your Partner',
            description: 'Connect with your partner through the app',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.psychology,
            title: 'Answer Questions',
            description: 'Both answer quick questions about your mood',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.auto_awesome,
            title: 'Get AI Suggestions',
            description: 'Receive personalized date ideas powered by AI',
          ),
          const SizedBox(height: 12),
          _FeatureCard(
            icon: Icons.favorite_border,
            title: 'Pick & Match',
            description: 'Select favorites and let AI find the perfect match',
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFF5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Color(0xFFE91C40), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Color(0xFF757575),
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

class _DateRequestsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DateRequestsListScreen();
  }
}

class _PartnersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('Not authenticated'));
    }

    return FutureBuilder<UserModel?>(
      future: authService.getUserData(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data;
        final partnerIds = user?.partnerIds ?? [];

        if (partnerIds.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                      Icons.people_outline,
                      size: 60,
                      color: Color(0xFFE91C40),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No Partners Added',
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E2E2E),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Invite your partner to start planning dates together',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PartnerDiscoveryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: Text(
                      'Invite Partner',
                      style: GoogleFonts.raleway(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6B4CE6),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: partnerIds.length + 1,
          itemBuilder: (context, index) {
            if (index == partnerIds.length) {
              // Add partner button at the end
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PartnerDiscoveryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add),
                  label: Text(
                    'Add Another Partner',
                    style: GoogleFonts.raleway(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Color(0xFFE91C40),
                    side: const BorderSide(color: Color(0xFFE91C40), width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              );
            }

            return FutureBuilder<UserModel?>(
              future: authService.getUserData(partnerIds[index]),
              builder: (context, partnerSnapshot) {
                final partner = partnerSnapshot.data;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: partner?.photoURL != null
                                  ? NetworkImage(partner!.photoURL!)
                                  : null,
                              child: partner?.photoURL == null
                                  ? Text(
                                      partner?.displayName?[0].toUpperCase() ??
                                          '?',
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    partner?.displayName ?? 'Loading...',
                                    style: GoogleFonts.raleway(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (partner?.email != null)
                                    Text(
                                      partner!.email,
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
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: partner == null
                                ? null
                                : () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DateModeSelectionScreen(
                                          partner: partner,
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.calendar_month),
                            label: Text(
                              'Plan a Date',
                              style: GoogleFonts.raleway(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6B4CE6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final User? user;
  final AuthService authService;

  const _ProfileTab({required this.user, required this.authService});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null
                ? Icon(Icons.person, size: 50, color: Color(0xFFE91C40))
                : null,
            backgroundColor: Color(0xFFFFF5F7),
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'User',
            style: GoogleFonts.raleway(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E2E2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user?.email ?? '',
            style: GoogleFonts.raleway(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
          if (user?.phoneNumber != null) ...[
            const SizedBox(height: 4),
            Text(
              user!.phoneNumber!,
              style: GoogleFonts.raleway(
                fontSize: 14,
                color: Color(0xFF757575),
              ),
            ),
          ],
          const SizedBox(height: 40),

          // Profile Options
          _ProfileOption(
            icon: Icons.edit,
            title: 'Edit Profile',
            onTap: () async {
              // Navigate to profile completion screen for editing
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ProfileCompletionScreen(isEditing: true),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _ProfileOption(
            icon: Icons.phone,
            title: 'Phone Number',
            onTap: () {
              _showPhoneNumberDialog(context, user, authService);
            },
          ),
          const SizedBox(height: 12),
          _ProfileOption(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            onTap: () async {
              final uri = Uri.parse('https://sites.google.com/view/soulplan');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open Privacy Policy')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 12),
          _ProfileOption(
            icon: Icons.logout,
            title: 'Sign Out',
            isDestructive: true,
            onTap: () async {
              final confirmed = await _showConfirmDialog(
                context,
                'Sign Out',
                'Are you sure you want to sign out?',
              );
              if (confirmed == true) {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              }
            },
          ),
          const SizedBox(height: 12),
          _ProfileOption(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            isDestructive: true,
            onTap: () async {
              final confirmed = await _showConfirmDialog(
                context,
                'Delete Account',
                'Are you sure? This action cannot be undone. All your data will be permanently deleted.',
              );
              if (confirmed == true && context.mounted) {
                try {
                  await authService.deleteAccount();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('Error deleting account: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
            Icon(
              icon,
              color: isDestructive ? Colors.red[400] : Color(0xFFE91C40),
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.raleway(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red[400] : Color(0xFF2E2E2E),
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9E9E9E),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show confirmation dialog
Future<bool?> _showConfirmDialog(
  BuildContext context,
  String title,
  String message,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        title,
        style: GoogleFonts.raleway(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E2E2E),
        ),
      ),
      content: Text(
        message,
        style: GoogleFonts.raleway(
          color: Color(0xFF757575),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Cancel',
            style: GoogleFonts.raleway(
              color: Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            'Confirm',
            style: GoogleFonts.raleway(
              color: Color(0xFFE91C40),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// Helper function to show phone number dialog
void _showPhoneNumberDialog(
  BuildContext context,
  User? user,
  AuthService authService,
) {
  final TextEditingController phoneController = TextEditingController();

  // Pre-fill with current phone number if available
  if (user?.phoneNumber != null) {
    phoneController.text = user!.phoneNumber!;
  }

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        'Phone Number',
        style: GoogleFonts.raleway(
          fontWeight: FontWeight.bold,
          color: Color(0xFF2E2E2E),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your phone number',
            style: GoogleFonts.raleway(
              color: Color(0xFF757575),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.raleway(
              color: Color(0xFF2E2E2E),
            ),
            decoration: InputDecoration(
              hintText: '+1234567890',
              hintStyle: GoogleFonts.raleway(
                color: Color(0xFF9E9E9E),
              ),
              prefixIcon: Icon(
                Icons.phone,
                color: Color(0xFFE91C40),
              ),
              filled: true,
              fillColor: Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Color(0xFFE91C40), width: 2),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.raleway(
              color: Color(0xFF757575),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            final phoneNumber = phoneController.text.trim();
            if (phoneNumber.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Please enter a phone number'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }

            try {
              // Update phone number in Firestore
              if (user != null) {
                await authService.updateUserProfile(user.uid, {
                  'phoneNumber': phoneNumber,
                });

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Phone number updated successfully'),
                      backgroundColor: Color(0xFFE91C40),
                    ),
                  );
                }
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Error updating phone number: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: Text(
            'Save',
            style: GoogleFonts.raleway(
              color: Color(0xFFE91C40),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}
