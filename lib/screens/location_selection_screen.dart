import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';

class LocationSelectionScreen extends StatefulWidget {
  const LocationSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LocationSelectionScreen> createState() =>
      _LocationSelectionScreenState();
}

class _LocationSelectionScreenState extends State<LocationSelectionScreen> {
  final TextEditingController _cityController = TextEditingController();
  bool _isLoadingLocation = false;
  String? _detectedLocation;
  Position? _currentPosition;
  List<String> _filteredCities = [];
  bool _showSuggestions = false;

  // Comprehensive list of international cities for autocomplete
  final List<String> _allCities = [
    // United States
    'New York, USA',
    'Los Angeles, USA',
    'Chicago, USA',
    'San Francisco, USA',
    'Miami, USA',
    'Las Vegas, USA',
    'Seattle, USA',
    'Boston, USA',
    'Austin, USA',
    'Denver, USA',

    // Europe
    'London, UK',
    'Paris, France',
    'Rome, Italy',
    'Barcelona, Spain',
    'Madrid, Spain',
    'Amsterdam, Netherlands',
    'Berlin, Germany',
    'Munich, Germany',
    'Vienna, Austria',
    'Prague, Czech Republic',
    'Budapest, Hungary',
    'Warsaw, Poland',
    'Krakow, Poland',
    'Athens, Greece',
    'Lisbon, Portugal',
    'Dublin, Ireland',
    'Brussels, Belgium',
    'Copenhagen, Denmark',
    'Stockholm, Sweden',
    'Oslo, Norway',
    'Helsinki, Finland',
    'Zurich, Switzerland',
    'Geneva, Switzerland',
    'Milan, Italy',
    'Venice, Italy',
    'Florence, Italy',
    'Edinburgh, UK',
    'Manchester, UK',

    // Asia
    'Tokyo, Japan',
    'Seoul, South Korea',
    'Bangkok, Thailand',
    'Singapore',
    'Hong Kong',
    'Dubai, UAE',
    'Mumbai, India',
    'Delhi, India',
    'Bangalore, India',
    'Shanghai, China',
    'Beijing, China',
    'Taipei, Taiwan',
    'Manila, Philippines',
    'Kuala Lumpur, Malaysia',
    'Jakarta, Indonesia',
    'Bali, Indonesia',
    'Hanoi, Vietnam',
    'Ho Chi Minh City, Vietnam',
    'Istanbul, Turkey',
    'Tel Aviv, Israel',

    // Oceania
    'Sydney, Australia',
    'Melbourne, Australia',
    'Brisbane, Australia',
    'Perth, Australia',
    'Auckland, New Zealand',
    'Wellington, New Zealand',

    // Middle East
    'Doha, Qatar',
    'Abu Dhabi, UAE',
    'Riyadh, Saudi Arabia',
    'Muscat, Oman',
    'Amman, Jordan',
    'Beirut, Lebanon',

    // Africa
    'Cairo, Egypt',
    'Johannesburg, South Africa',
    'Cape Town, South Africa',
    'Nairobi, Kenya',
    'Marrakech, Morocco',
    'Casablanca, Morocco',
    'Lagos, Nigeria',
    'Tunis, Tunisia',

    // Latin America
    'Mexico City, Mexico',
    'Cancun, Mexico',
    'Buenos Aires, Argentina',
    'Rio de Janeiro, Brazil',
    'São Paulo, Brazil',
    'Lima, Peru',
    'Santiago, Chile',
    'Bogota, Colombia',
    'Medellin, Colombia',
    'Cartagena, Colombia',
    'Montevideo, Uruguay',
    'Quito, Ecuador',
    'Panama City, Panama',
    'San Jose, Costa Rica',

    // Canada
    'Toronto, Canada',
    'Vancouver, Canada',
    'Montreal, Canada',
    'Calgary, Canada',
    'Ottawa, Canada',
  ];

  // Popular cities for quick selection
  List<String> get _popularCities => _allCities.take(20).toList();

  @override
  void initState() {
    super.initState();
    _cityController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _cityController.removeListener(_onSearchChanged);
    _cityController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _cityController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _showSuggestions = false;
        _filteredCities = [];
      });
    } else {
      setState(() {
        _showSuggestions = true;
        _filteredCities = _allCities
            .where((city) => city.toLowerCase().contains(query))
            .take(5)
            .toList();
      });
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
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF2E2E2E),
          ),
        ),
        title: Text(
          'Choose Location',
          style: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2E2E2E),
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Subtitle
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Text(
                'Where do you want to plan your date?',
                style: GoogleFonts.raleway(
                  fontSize: 15,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // GPS Detection Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location,
                              size: 40,
                              color: Color(0xFFE91C40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Use Current Location',
                            style: GoogleFonts.raleway(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E2E2E),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_detectedLocation != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _detectedLocation!,
                                style: GoogleFonts.raleway(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isLoadingLocation
                                  ? null
                                  : _detectCurrentLocation,
                              icon: _isLoadingLocation
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.gps_fixed),
                              label: Text(
                                _isLoadingLocation
                                    ? 'Detecting...'
                                    : 'Detect Location',
                                style: GoogleFonts.raleway(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91C40),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          if (_detectedLocation != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: SizedBox(
                                width: double.infinity,
                                child: OutlinedButton(
                                  onPressed: () => _selectLocation(
                                    _detectedLocation!,
                                    _currentPosition,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFFE91C40),
                                    side: const BorderSide(
                                      color: Color(0xFFE91C40),
                                      width: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: Text(
                                    'Use This Location',
                                    style: GoogleFonts.raleway(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Divider
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: GoogleFonts.raleway(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Manual Input Card with Autocomplete
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFEBEE),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit_location_alt,
                              size: 40,
                              color: Color(0xFFE91C40),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter City',
                            style: GoogleFonts.raleway(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E2E2E),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _cityController,
                            decoration: InputDecoration(
                              hintText: 'e.g., San Francisco, CA',
                              hintStyle: GoogleFonts.raleway(
                                color: Colors.grey[400],
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Color(0xFFE91C40),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[200]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Color(0xFFE91C40),
                                  width: 2,
                                ),
                              ),
                            ),
                            onSubmitted: (value) {
                              if (value.isNotEmpty) {
                                _selectLocation(value, null);
                              }
                            },
                          ),

                          // Autocomplete Suggestions
                          if (_showSuggestions && _filteredCities.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredCities.length,
                                separatorBuilder: (context, index) => Divider(
                                  height: 1,
                                  color: Colors.grey[200],
                                ),
                                itemBuilder: (context, index) {
                                  final city = _filteredCities[index];
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.location_on,
                                      color: Color(0xFFE91C40),
                                      size: 20,
                                    ),
                                    title: Text(
                                      city,
                                      style: GoogleFonts.raleway(
                                        fontSize: 14,
                                        color: const Color(0xFF2E2E2E),
                                      ),
                                    ),
                                    onTap: () {
                                      _cityController.text = city;
                                      setState(() {
                                        _showSuggestions = false;
                                      });
                                      _selectLocation(city, null);
                                    },
                                  );
                                },
                              ),
                            ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_cityController.text.isNotEmpty) {
                                  _selectLocation(_cityController.text, null);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE91C40),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Continue',
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

                    const SizedBox(height: 32),

                    // Popular Cities
                    Text(
                      'Popular Cities',
                      style: GoogleFonts.raleway(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2E2E2E),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _popularCities.map((city) {
                        return ActionChip(
                          label: Text(city),
                          labelStyle: GoogleFonts.raleway(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2E2E2E),
                          ),
                          backgroundColor: Colors.grey[100],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey[300]!),
                          ),
                          onPressed: () => _selectLocation(city, null),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied. Please enable them in Settings.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String location =
            '${place.locality ?? ''}, ${place.administrativeArea ?? ''}';

        setState(() {
          _detectedLocation = location.trim();
          _currentPosition = position;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error detecting location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _selectLocation(String location, Position? position) {
    Navigator.pop(context, {
      'location': location,
      'coordinates': position != null
          ? {
              'latitude': position.latitude,
              'longitude': position.longitude,
            }
          : null,
    });
  }
}
