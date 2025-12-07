import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/date_request_model.dart';
import '../services/places_service.dart';
import 'place_details_screen.dart';

class VenueSelectionScreen extends StatefulWidget {
  final String dateRequestId;

  const VenueSelectionScreen({
    super.key,
    required this.dateRequestId,
  });

  @override
  State<VenueSelectionScreen> createState() => _VenueSelectionScreenState();
}

class _VenueSelectionScreenState extends State<VenueSelectionScreen> {
  final PlacesService _placesService = PlacesService();
  List<Map<String, dynamic>> _venues = [];
  bool _isLoading = true;
  String _errorMessage = '';
  DateRequestModel? _dateRequest;

  @override
  void initState() {
    super.initState();
    _loadDateRequestAndVenues();
  }

  Future<void> _loadDateRequestAndVenues() async {
    try {
      // Load date request to get matched date details
      final doc = await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .get();

      if (!doc.exists) {
        setState(() {
          _errorMessage = 'Date request not found';
          _isLoading = false;
        });
        return;
      }

      final dateRequest = DateRequestModel.fromFirestore(doc);
      final selectedDate = dateRequest.selectedDate;

      if (selectedDate == null) {
        setState(() {
          _errorMessage = 'No matched date found';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _dateRequest = dateRequest;
      });

      // Extract search parameters from matched date
      final title = selectedDate['title'] ?? '';
      final location = dateRequest.location ?? 'San Francisco';
      final cost = selectedDate['cost'] ?? '\$\$';

      // Determine category based on activities
      final activities =
          (selectedDate['activities'] as List?)?.cast<String>() ?? [];
      String category = _determineCategoryFromActivities(activities, title);

      // Search for venues
      final venues = await _placesService.getPlaces(
        title,
        location,
        cost,
        category,
      );

      setState(() {
        _venues = venues;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load venues: $e';
        _isLoading = false;
      });
    }
  }

  String _determineCategoryFromActivities(
      List<String> activities, String title) {
    // Map activities/title to Foursquare categories
    final lowerActivities = activities.map((a) => a.toLowerCase()).toList();
    final lowerTitle = title.toLowerCase();

    if (lowerActivities.any((a) => a.contains('dinner') || a.contains('restaurant')) ||
        lowerTitle.contains('dinner')) {
      return 'dinner';
    } else if (lowerActivities
            .any((a) => a.contains('movie') || a.contains('cinema')) ||
        lowerTitle.contains('movie')) {
      return 'movie';
    } else if (lowerActivities
            .any((a) => a.contains('comedy') || a.contains('standup')) ||
        lowerTitle.contains('comedy')) {
      return 'standup_comedy';
    } else if (lowerActivities.any((a) => a.contains('park') || a.contains('outdoor') || a.contains('hike')) ||
        lowerTitle.contains('outdoor')) {
      return 'outdoor_activity';
    } else if (lowerActivities.any((a) =>
            a.contains('museum') ||
            a.contains('art') ||
            a.contains('gallery')) ||
        lowerTitle.contains('museum') ||
        lowerTitle.contains('art')) {
      return 'cultural';
    } else if (lowerActivities.any((a) =>
            a.contains('bar') ||
            a.contains('club') ||
            a.contains('nightlife')) ||
        lowerTitle.contains('bar') ||
        lowerTitle.contains('club')) {
      return 'nightlife';
    } else if (lowerActivities.any((a) =>
            a.contains('spa') || a.contains('wellness') || a.contains('massage')) ||
        lowerTitle.contains('spa') ||
        lowerTitle.contains('relax')) {
      return 'relaxation';
    }

    // Default to dinner for romantic dates
    return 'dinner';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E2E2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Venue',
          style: TextStyle(
            color: Color(0xFF2E2E2E),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_dateRequest != null) _buildDateInfoCard(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFE91C40)),
                          SizedBox(height: 16),
                          Text(
                            'Finding perfect venues...',
                            style: GoogleFonts.raleway(
                              color: Color(0xFF757575),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _errorMessage.isNotEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFE91C40),
                                  size: 64,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  _errorMessage,
                                  style: GoogleFonts.raleway(
                                    color: Color(0xFF2E2E2E),
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                      _errorMessage = '';
                                    });
                                    _loadDateRequestAndVenues();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFE91C40),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _venues.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.search_off,
                                      color: Color(0xFF9E9E9E),
                                      size: 64,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'No venues found',
                                      style: GoogleFonts.raleway(
                                        color: Color(0xFF2E2E2E),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try searching in a different location',
                                      style: GoogleFonts.raleway(
                                        color: Color(0xFF757575),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : _buildVenuesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Venues',
                  style: GoogleFonts.raleway(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Perfect spots for your date',
                  style: GoogleFonts.raleway(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfoCard() {
    final selectedDate = _dateRequest!.selectedDate!;
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFF0F0F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event, color: Color(0xFFE91C40), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedDate['title'] ?? 'Your Date',
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                if (_dateRequest!.location != null)
                  Text(
                    _dateRequest!.location!,
                    style: GoogleFonts.raleway(
                      fontSize: 13,
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

  Widget _buildVenuesList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _venues.length,
            itemBuilder: (context, index) {
              final venue = _venues[index];
              return _buildVenueCard(venue);
            },
          ),
        ),
        // OpenStreetMap attribution (required)
        Container(
          padding: EdgeInsets.all(12),
          color: Colors.grey[50],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
              SizedBox(width: 6),
              Text(
                'Venue data \u00a9 ',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  // Open OpenStreetMap website
                  final url =
                      Uri.parse('https://www.openstreetmap.org/copyright');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  }
                },
                child: Text(
                  'OpenStreetMap contributors',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Color(0xFF6B4CE6),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(0xFFF0F0F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToVenueDetails(venue),
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue['name'] ?? 'Unknown Venue',
                        style: GoogleFonts.raleway(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D1B4E),
                        ),
                      ),
                    ),
                    if (venue['price'] != null && venue['price'] != 'N/A')
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(0xFF6B4CE6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          venue['price'],
                          style: GoogleFonts.raleway(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B4CE6),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      venue['category'] ?? 'Unknown Category',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.place,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        venue['address'] ?? 'Address not available',
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: GoogleFonts.raleway(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B4CE6),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Color(0xFF6B4CE6),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToVenueDetails(Map<String, dynamic> venue) async {
    try {
      // Load full venue details (pass entire venue object with OSM type/ID)
      final placeDetails = await _placesService.getPlaceDetails(venue);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PlaceDetailsScreen(
            placeDetails: placeDetails,
            dateRequestId: widget.dateRequestId,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load venue details: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
