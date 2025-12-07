import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> favoriteDates = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteDates();
  }

  Future<void> _loadFavoriteDates() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
          favoriteDates = prefs.getStringList('favoriteDates') ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading favorites: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeFavorite(int index) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        favoriteDates.removeAt(index);
      });
      await prefs.setStringList('favoriteDates', favoriteDates);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed from favorites'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing favorite: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Color(0xFFE91C40).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: Color(0xFFE91C40),
              ),
            ),
            SizedBox(height: 32),
            Text(
              "No Favorite Dates Yet",
              style: GoogleFonts.lato(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              "Start exploring and save your favorite date ideas for quick access later.",
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Color(0xFF757575),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.explore),
              label: Text(
                "Explore Dates",
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE91C40),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).scale();
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: favoriteDates.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: Key('favorite_$index'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.delete, color: Colors.white, size: 32),
                SizedBox(height: 4),
                Text(
                  'Remove',
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  title: Text(
                    'Remove Favorite',
                    style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                  ),
                  content: Text(
                    'Are you sure you want to remove this from favorites?',
                    style: GoogleFonts.lato(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.lato(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Remove',
                        style: GoogleFonts.lato(color: Colors.white),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            _removeFavorite(index);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFFFFAFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFE91C40).withOpacity(0.1),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _showDateDetails(context, favoriteDates[index]);
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Color(0xFFE91C40).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: Color(0xFFE91C40),
                          size: 28,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitle(favoriteDates[index]),
                              style: GoogleFonts.lato(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E2E2E),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6),
                            Text(
                              _getDescription(favoriteDates[index]),
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: Color(0xFF757575),
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFE91C40).withOpacity(0.5),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: (index * 100).ms)
              .slideX(begin: 0.2, end: 0),
        );
      },
    );
  }

  String _getTitle(String suggestion) {
    final parts = suggestion.split('\n');
    return parts.isNotEmpty ? parts[0].trim() : "Date Suggestion";
  }

  String _getDescription(String suggestion) {
    final parts = suggestion.split('\n');
    if (parts.length > 1) {
      return parts.sublist(1).join('\n').trim();
    }
    return '';
  }

  void _showDateDetails(BuildContext context, String suggestion) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFE91C40).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.favorite,
                      color: Color(0xFFE91C40),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      _getTitle(suggestion),
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E2E2E),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Text(
                  suggestion,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Color(0xFF2E2E2E),
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E2E2E)),
          onPressed: () => Navigator.pop(context),
        ).animate().fadeIn(delay: 200.ms),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Color(0xFFE91C40), size: 24),
            SizedBox(width: 8),
            Text(
              "Favorite Dates",
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms).slideX(),
        centerTitle: true,
        actions: [
          if (favoriteDates.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFE91C40).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${favoriteDates.length}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFE91C40),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms).scale(),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(2),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFE91C40).withOpacity(0.3),
                  Color(0xFFFF6B9D).withOpacity(0.3),
                ],
              ),
            ),
            height: 2,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Color(0xFFE91C40),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading favorites...',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            )
          : favoriteDates.isEmpty
              ? _buildEmptyState()
              : _buildFavoritesList(),
    );
  }
}
