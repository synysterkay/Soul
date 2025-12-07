import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final bool isEditing;

  const ProfileCompletionScreen({Key? key, this.isEditing = false})
      : super(key: key);

  @override
  State<ProfileCompletionScreen> createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  bool _isLoadingData = false;

  // Profile data
  String? _selectedGender;
  final List<String> _selectedInterests = [];
  final List<String> _selectedHobbies = [];
  String? _relationshipStatus;
  String? _personalityType;
  final List<String> _selectedDatePreferences = [];
  String? _budgetPreference;
  final TextEditingController _bioController = TextEditingController();

  // Options
  final List<Map<String, dynamic>> _genders = [
    {'value': 'male', 'label': 'Male', 'icon': Icons.male},
    {'value': 'female', 'label': 'Female', 'icon': Icons.female},
    {'value': 'non_binary', 'label': 'Non-binary', 'icon': Icons.transgender},
    {
      'value': 'prefer_not_to_say',
      'label': 'Prefer not to say',
      'icon': Icons.help_outline
    },
  ];

  final List<Map<String, String>> _interests = [
    {'value': 'food', 'label': 'Food & Dining', 'icon': '🍽️'},
    {'value': 'travel', 'label': 'Travel', 'icon': '✈️'},
    {'value': 'fitness', 'label': 'Fitness', 'icon': '💪'},
    {'value': 'arts', 'label': 'Arts & Culture', 'icon': '🎨'},
    {'value': 'music', 'label': 'Music', 'icon': '🎵'},
    {'value': 'movies', 'label': 'Movies & TV', 'icon': '🎬'},
    {'value': 'gaming', 'label': 'Gaming', 'icon': '🎮'},
    {'value': 'reading', 'label': 'Reading', 'icon': '📚'},
    {'value': 'sports', 'label': 'Sports', 'icon': '⚽'},
    {'value': 'nature', 'label': 'Nature & Outdoors', 'icon': '🌲'},
    {'value': 'photography', 'label': 'Photography', 'icon': '📷'},
    {'value': 'cooking', 'label': 'Cooking', 'icon': '👨‍🍳'},
  ];

  final List<Map<String, String>> _hobbies = [
    {'value': 'hiking', 'label': 'Hiking', 'icon': '🥾'},
    {'value': 'yoga', 'label': 'Yoga', 'icon': '🧘'},
    {'value': 'painting', 'label': 'Painting', 'icon': '🎨'},
    {'value': 'dancing', 'label': 'Dancing', 'icon': '💃'},
    {'value': 'writing', 'label': 'Writing', 'icon': '✍️'},
    {'value': 'cycling', 'label': 'Cycling', 'icon': '🚴'},
    {'value': 'swimming', 'label': 'Swimming', 'icon': '🏊'},
    {'value': 'gardening', 'label': 'Gardening', 'icon': '🌱'},
    {'value': 'meditation', 'label': 'Meditation', 'icon': '🧘‍♀️'},
    {'value': 'baking', 'label': 'Baking', 'icon': '🧁'},
    {'value': 'crafting', 'label': 'Crafting', 'icon': '✂️'},
    {'value': 'volunteering', 'label': 'Volunteering', 'icon': '🤝'},
  ];

  final List<Map<String, String>> _relationshipStatuses = [
    {'value': 'single', 'label': 'Single', 'icon': '💔'},
    {'value': 'dating', 'label': 'Dating', 'icon': '💑'},
    {'value': 'in_relationship', 'label': 'In a Relationship', 'icon': '❤️'},
    {'value': 'engaged', 'label': 'Engaged', 'icon': '💍'},
    {'value': 'married', 'label': 'Married', 'icon': '💒'},
  ];

  final List<Map<String, String>> _personalityTypes = [
    {'value': 'adventurous', 'label': 'Adventurous', 'icon': '🏔️'},
    {'value': 'romantic', 'label': 'Romantic', 'icon': '💝'},
    {'value': 'intellectual', 'label': 'Intellectual', 'icon': '🧠'},
    {'value': 'social', 'label': 'Social Butterfly', 'icon': '🦋'},
    {'value': 'homebody', 'label': 'Homebody', 'icon': '🏠'},
    {'value': 'spontaneous', 'label': 'Spontaneous', 'icon': '⚡'},
    {'value': 'planner', 'label': 'Planner', 'icon': '📋'},
    {'value': 'creative', 'label': 'Creative', 'icon': '🎭'},
  ];

  final List<Map<String, String>> _datePreferences = [
    {'value': 'outdoor', 'label': 'Outdoor Activities', 'icon': '🌳'},
    {'value': 'indoor', 'label': 'Indoor Activities', 'icon': '🏛️'},
    {'value': 'restaurants', 'label': 'Restaurants', 'icon': '🍽️'},
    {'value': 'cultural', 'label': 'Cultural Events', 'icon': '🎭'},
    {'value': 'adventurous', 'label': 'Adventurous', 'icon': '🎢'},
    {'value': 'relaxing', 'label': 'Relaxing', 'icon': '🧘'},
    {'value': 'nightlife', 'label': 'Nightlife', 'icon': '🌃'},
    {'value': 'daytime', 'label': 'Daytime', 'icon': '☀️'},
  ];

  final List<Map<String, String>> _budgetPreferences = [
    {
      'value': 'budget',
      'label': 'Budget-Friendly',
      'icon': '💰',
      'desc': 'Under \$50'
    },
    {
      'value': 'moderate',
      'label': 'Moderate',
      'icon': '💳',
      'desc': '\$50 - \$150'
    },
    {'value': 'luxury', 'label': 'Luxury', 'icon': '💎', 'desc': 'Over \$150'},
    {
      'value': 'flexible',
      'label': 'Flexible',
      'icon': '🔄',
      'desc': 'Depends on activity'
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingProfile();
    }
  }

  Future<void> _loadExistingProfile() async {
    setState(() => _isLoadingData = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _selectedGender = data['gender'];
          if (data['interests'] != null) {
            _selectedInterests.addAll(List<String>.from(data['interests']));
          }
          if (data['hobbies'] != null) {
            _selectedHobbies.addAll(List<String>.from(data['hobbies']));
          }
          _relationshipStatus = data['relationshipStatus'];
          _personalityType = data['personalityType'];
          if (data['datePreferences'] != null) {
            _selectedDatePreferences
                .addAll(List<String>.from(data['datePreferences']));
          }
          _budgetPreference = data['budgetPreference'];
          _bioController.text = data['bio'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('No user logged in');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'gender': _selectedGender,
        'interests': _selectedInterests,
        'hobbies': _selectedHobbies,
        'relationshipStatus': _relationshipStatus,
        'personalityType': _personalityType,
        'datePreferences': _selectedDatePreferences,
        'budgetPreference': _budgetPreference,
        'bio': _bioController.text.trim(),
        'isProfileComplete': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context)
            .pop(true); // Return true to indicate profile completed
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedGender != null;
      case 1:
        return _selectedInterests.length >= 3;
      case 2:
        return _selectedHobbies.length >= 2;
      case 3:
        return _relationshipStatus != null;
      case 4:
        return _personalityType != null;
      case 5:
        return _selectedDatePreferences.length >= 2;
      case 6:
        return _budgetPreference != null;
      case 7:
        return _bioController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _nextPage() {
    if (_currentPage < 7) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _saveProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFE91C40)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (_currentPage > 0 || widget.isEditing)
                      IconButton(
                        icon: Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
                        onPressed: () {
                          if (_currentPage > 0) {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.isEditing
                                ? 'Edit Your Profile'
                                : 'Complete Your Profile',
                            style: GoogleFonts.lato(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: (_currentPage + 1) / 8,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_currentPage + 1}/8',
                      style: GoogleFonts.lato(
                        color: Color(0xFF757575),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  children: [
                    _buildGenderPage(),
                    _buildInterestsPage(),
                    _buildHobbiesPage(),
                    _buildRelationshipStatusPage(),
                    _buildPersonalityTypePage(),
                    _buildDatePreferencesPage(),
                    _buildBudgetPage(),
                    _buildBioPage(),
                  ],
                ),
              ),

              // Next Button
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                        _canProceed() ? (_isLoading ? null : _nextPage) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFE91C40),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Color(0xFFE0E0E0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Color(0xFFE91C40))
                        : Text(
                            _currentPage == 7
                                ? (widget.isEditing
                                    ? 'Save Changes'
                                    : 'Complete Profile')
                                : 'Continue',
                            style: GoogleFonts.lato(
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

  Widget _buildGenderPage() {
    return _buildPage(
      title: 'What\'s your gender?',
      subtitle: 'Help us personalize your experience',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _genders.map((gender) {
          final isSelected = _selectedGender == gender['value'];
          return _buildChoiceChip(
            label: gender['label'] as String,
            icon: gender['icon'] as IconData,
            isSelected: isSelected,
            onTap: () =>
                setState(() => _selectedGender = gender['value'] as String),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInterestsPage() {
    return _buildPage(
      title: 'What are your interests?',
      subtitle: 'Select at least 3 things you enjoy',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _interests.map((interest) {
          final isSelected = _selectedInterests.contains(interest['value']);
          return _buildEmojiChip(
            label: interest['label']!,
            emoji: interest['icon']!,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedInterests.remove(interest['value']);
                } else {
                  _selectedInterests.add(interest['value']!);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHobbiesPage() {
    return _buildPage(
      title: 'What hobbies do you have?',
      subtitle: 'Select at least 2 hobbies',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _hobbies.map((hobby) {
          final isSelected = _selectedHobbies.contains(hobby['value']);
          return _buildEmojiChip(
            label: hobby['label']!,
            emoji: hobby['icon']!,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedHobbies.remove(hobby['value']);
                } else {
                  _selectedHobbies.add(hobby['value']!);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRelationshipStatusPage() {
    return _buildPage(
      title: 'Relationship status?',
      subtitle: 'This helps us tailor date suggestions',
      child: Column(
        children: _relationshipStatuses.map((status) {
          final isSelected = _relationshipStatus == status['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildStatusCard(
              label: status['label']!,
              emoji: status['icon']!,
              isSelected: isSelected,
              onTap: () =>
                  setState(() => _relationshipStatus = status['value']),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPersonalityTypePage() {
    return _buildPage(
      title: 'What\'s your personality?',
      subtitle: 'Choose the one that fits you best',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _personalityTypes.map((type) {
          final isSelected = _personalityType == type['value'];
          return _buildEmojiChip(
            label: type['label']!,
            emoji: type['icon']!,
            isSelected: isSelected,
            onTap: () => setState(() => _personalityType = type['value']),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDatePreferencesPage() {
    return _buildPage(
      title: 'Date preferences?',
      subtitle: 'Select at least 2 preferences',
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: _datePreferences.map((pref) {
          final isSelected = _selectedDatePreferences.contains(pref['value']);
          return _buildEmojiChip(
            label: pref['label']!,
            emoji: pref['icon']!,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDatePreferences.remove(pref['value']);
                } else {
                  _selectedDatePreferences.add(pref['value']!);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBudgetPage() {
    return _buildPage(
      title: 'Budget preference?',
      subtitle: 'What\'s your typical date budget?',
      child: Column(
        children: _budgetPreferences.map((budget) {
          final isSelected = _budgetPreference == budget['value'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildBudgetCard(
              label: budget['label']!,
              emoji: budget['icon']!,
              description: budget['desc']!,
              isSelected: isSelected,
              onTap: () => setState(() => _budgetPreference = budget['value']),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBioPage() {
    return _buildPage(
      title: 'Tell us about yourself',
      subtitle: 'Write a short bio (50-200 characters)',
      child: TextField(
        controller: _bioController,
        maxLines: 5,
        maxLength: 200,
        style: GoogleFonts.lato(fontSize: 16),
        decoration: InputDecoration(
          hintText:
              'I love exploring new places, trying different cuisines, and...',
          hintStyle: GoogleFonts.lato(color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          counterStyle: GoogleFonts.lato(color: Colors.white),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildPage(
      {required String title,
      required String subtitle,
      required Widget child}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.lato(
              color: Color(0xFF2E2E2E),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.lato(
              color: Color(0xFF757575),
              fontSize: 16,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          child.animate().fadeIn(delay: 300.ms),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFF5F7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFFE91C40) : Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFE91C40).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Color(0xFFE91C40) : Color(0xFF757575),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.lato(
                color: isSelected ? Color(0xFFE91C40) : Color(0xFF757575),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmojiChip({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFF5F7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFFE91C40) : Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFE91C40).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.lato(
                color: isSelected ? Color(0xFFE91C40) : Color(0xFF757575),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required String label,
    required String emoji,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFF5F7) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Color(0xFFE91C40) : Color(0xFFE0E0E0),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(0xFFE91C40).withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Text(
              label,
              style: GoogleFonts.lato(
                color: isSelected ? Color(0xFFE91C40) : Color(0xFF757575),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetCard({
    required String label,
    required String emoji,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.lato(
                      color: isSelected ? Color(0xFFE91C40) : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.lato(
                      color: isSelected
                          ? Color(0xFFE91C40).withOpacity(0.7)
                          : Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
