import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soul_plan/services/places_service.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PlaceDetailsScreen extends StatefulWidget {
  final String? placeId;
  final String? placeName;
  final Map<String, dynamic>? placeDetails;
  final String? dateRequestId;

  const PlaceDetailsScreen({
    Key? key,
    this.placeId,
    this.placeName,
    this.placeDetails,
    this.dateRequestId,
  }) : super(key: key);

  @override
  _PlaceDetailsScreenState createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends State<PlaceDetailsScreen> {
  final PlacesService _placesService = PlacesService();
  Map<String, dynamic>? _placeDetails;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.placeDetails != null) {
      _placeDetails = widget.placeDetails;
      _isLoading = false;
    } else if (widget.placeId != null) {
      _loadPlaceDetails();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadPlaceDetails() async {
    try {
      final details = await _placesService.getPlaceDetails(widget.placeId!);
      setState(() {
        _placeDetails = details;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectVenue() async {
    if (_placeDetails == null || widget.dateRequestId == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      // Update the date request with selected venue
      await FirebaseFirestore.instance
          .collection('dateRequests')
          .doc(widget.dateRequestId)
          .update({
        'selectedDate.venue': _placeDetails!['name'],
        'selectedDate.venueAddress': _placeDetails!['address'],
        'selectedDate.venueCategory': _placeDetails!['category'],
        'selectedDate.venuePhone': _placeDetails!['phone'],
        'selectedDate.venueWebsite': _placeDetails!['website'],
        'selectedDate.venueId': _placeDetails!['id'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Venue selected successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Go back to time negotiation screen
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select venue: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _openInGoogleMaps() async {
    if (_placeDetails == null) return;

    final lat = _placeDetails!['lat'];
    final lon = _placeDetails!['lon'];
    final name = Uri.encodeComponent(_placeDetails!['name'] ?? 'Venue');

    // Try Google Maps app first, fallback to web
    final googleMapsUrl = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lon&query_place_id=$name');

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      } else {
        throw 'Could not open Google Maps';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Google Maps'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Color(0xFF2E2E2E)),
          onPressed: () => Navigator.pop(context),
        ).animate().fadeIn(delay: 200.ms),
        title: Text(
          widget.placeName ?? _placeDetails?['name'] ?? 'Venue Details',
          style: GoogleFonts.lato(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E2E2E),
          ),
        ).animate().fadeIn(delay: 300.ms).slideX(),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.grey[200],
            height: 1,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE91C40)),
              ),
            )
          : _placeDetails == null
              ? _buildErrorWidget()
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageSlideshow(),
                      _buildDetailsCard(),
                      if (widget.dateRequestId != null)
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // Open in Google Maps button (secondary action)
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: _openInGoogleMaps,
                                  icon: Icon(Icons.map, size: 20),
                                  label: Text(
                                    'Open in Google Maps',
                                    style: GoogleFonts.raleway(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Color(0xFFE91C40),
                                    side: BorderSide(
                                        color: Color(0xFFE91C40), width: 2),
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 12),
                              // Select This Venue button (primary action)
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _selectVenue,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF6B4CE6),
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle, size: 20),
                                            SizedBox(width: 8),
                                            Text(
                                              'Select This Venue',
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
                      SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24),
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Failed to load place details',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPlaceDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFE91C40),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Retry',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY();
  }

  Widget _buildImageSlideshow() {
    List<String> photos =
        (_placeDetails!['photos'] as List<dynamic>?)?.cast<String>() ?? [];

    // OpenStreetMap doesn't provide photos, show placeholder
    if (photos.isEmpty) {
      return Container(
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE91C40),
              Color(0xFF6B4CE6),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.place,
                size: 80,
                color: Colors.white.withOpacity(0.9),
              ),
              SizedBox(height: 16),
              Text(
                _placeDetails!['name'] ?? 'Venue',
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '© OpenStreetMap',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms);
    }

    return Container(
      height: 250,
      child: ImageSlideshow(
        width: double.infinity,
        height: 250,
        initialPage: 0,
        indicatorColor: Color(0xFFE91C40),
        indicatorBackgroundColor: Colors.grey[300],
        children: photos
            .map((photo) => Image.network(
                  photo,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[100],
                      child:
                          Icon(Icons.error, color: Color(0xFFE91C40), size: 50),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFFE91C40)),
                      ),
                    );
                  },
                ))
            .toList(),
        autoPlayInterval: 3000,
        isLoop: true,
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildDetailsCard() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _placeDetails!['name'],
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E2E),
              ),
            ).animate().fadeIn(delay: 300.ms),
            SizedBox(height: 12),
            Text(
              _placeDetails!['description'],
              style: GoogleFonts.lato(
                fontSize: 16,
                height: 1.5,
                color: Colors.grey[600],
              ),
            ).animate().fadeIn(delay: 400.ms),
            SizedBox(height: 24),
            ..._buildInfoRows(),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY();
  }

  List<Widget> _buildInfoRows() {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.location_on,
        'label': 'Address',
        'value': _placeDetails!['address']
      },
      {
        'icon': Icons.category,
        'label': 'Category',
        'value': _placeDetails!['category']
      },
      // Only show price if not default
      if (_placeDetails!['price'] != null && _placeDetails!['price'] != 'N/A')
        {
          'icon': Icons.attach_money,
          'label': 'Price Range',
          'value': _placeDetails!['price']
        },
      // Only show rating if > 0
      if (_placeDetails!['rating'] != null &&
          (_placeDetails!['rating'] as num) > 0)
        {
          'icon': Icons.star,
          'label': 'Rating',
          'value': '${_placeDetails!['rating']}/5.0'
        },
      // Only show website if available
      if (_placeDetails!['website'] != null &&
          _placeDetails!['website'] != 'N/A' &&
          _placeDetails!['website'].toString().isNotEmpty)
        {
          'icon': Icons.language,
          'label': 'Website',
          'value': _placeDetails!['website'],
          'isLink': true
        },
      // Only show phone if available
      if (_placeDetails!['phone'] != null &&
          _placeDetails!['phone'] != 'N/A' &&
          _placeDetails!['phone'].toString().isNotEmpty)
        {
          'icon': Icons.phone,
          'label': 'Phone',
          'value': _placeDetails!['phone']
        },
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      return _buildInfoRow(
        item['icon'] as IconData,
        item['label'] as String,
        item['value'] as String,
        isLink: item['isLink'] as bool? ?? false,
      ).animate().fadeIn(delay: (600 + (index * 100)).ms);
    }).toList();
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {bool isLink = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Color(0xFFE91C40), size: 24),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                isLink
                    ? GestureDetector(
                        onTap: () => launch(value),
                        child: Text(
                          value,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Color(0xFFE91C40),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          color: Color(0xFF2E2E2E),
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

class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GlassButton({Key? key, required this.text, required this.onPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFE91C40),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.lato(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
