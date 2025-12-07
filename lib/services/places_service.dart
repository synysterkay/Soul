import 'package:http/http.dart' as http;
import 'dart:convert';

class PlacesService {
  // Using OpenStreetMap Nominatim API (free, no key required)
  final String baseUrl = 'https://nominatim.openstreetmap.org';
  final String userAgent =
      'SoulPlan/1.0 (Date Planning App)'; // Required by OSM

  /// Extract key venue types from date description with enhanced matching
  List<String> _extractVenueTypes(String dateDescription) {
    final keywords = <String>[];
    final lower = dateDescription.toLowerCase();

    // Restaurant/Food keywords (expanded for AI-generated dates)
    if (lower.contains('restaurant') ||
        lower.contains('dinner') ||
        lower.contains('lunch') ||
        lower.contains('brunch') ||
        lower.contains('food') ||
        lower.contains('cuisine') ||
        lower.contains('meal') ||
        lower.contains('dine') ||
        lower.contains('eat') ||
        lower.contains('dining') ||
        lower.contains('chef') ||
        lower.contains('tasting') ||
        lower.contains('culinary') ||
        lower.contains('bistro') ||
        lower.contains('eatery')) {
      keywords.add('restaurant');
    }

    // Bar/Nightlife keywords (expanded)
    if (lower.contains('bar') ||
        lower.contains('cocktail') ||
        lower.contains('drink') ||
        lower.contains('nightlife') ||
        lower.contains('pub') ||
        lower.contains('wine') ||
        lower.contains('brewery') ||
        lower.contains('rooftop') ||
        lower.contains('lounge') ||
        lower.contains('speakeasy') ||
        lower.contains('tavern')) {
      keywords.add('bar');
    }

    // Entertainment keywords (expanded)
    if (lower.contains('movie') ||
        lower.contains('cinema') ||
        lower.contains('film') ||
        lower.contains('theater') ||
        lower.contains('theatre') ||
        lower.contains('show') ||
        lower.contains('performance') ||
        lower.contains('comedy') ||
        lower.contains('live music') ||
        lower.contains('concert')) {
      keywords.add('cinema');
    }

    // Museum/Cultural keywords (expanded)
    if (lower.contains('museum') ||
        lower.contains('gallery') ||
        lower.contains('art') ||
        lower.contains('exhibition') ||
        lower.contains('cultural') ||
        lower.contains('historic') ||
        lower.contains('monument') ||
        lower.contains('heritage') ||
        lower.contains('sculpture') ||
        lower.contains('paintings')) {
      keywords.add('museum');
    }

    // Outdoor/Nature keywords (expanded)
    if (lower.contains('park') ||
        lower.contains('garden') ||
        lower.contains('outdoor') ||
        lower.contains('nature') ||
        lower.contains('scenic') ||
        lower.contains('hike') ||
        lower.contains('trail') ||
        lower.contains('beach') ||
        lower.contains('picnic') ||
        lower.contains('sunset') ||
        lower.contains('sunrise') ||
        lower.contains('waterfront') ||
        lower.contains('lake') ||
        lower.contains('mountain') ||
        lower.contains('forest') ||
        lower.contains('botanical')) {
      keywords.add('park');
    }

    // Activity/Sports keywords (expanded)
    if (lower.contains('activity') ||
        lower.contains('sport') ||
        lower.contains('bowling') ||
        lower.contains('arcade') ||
        lower.contains('game') ||
        lower.contains('climbing') ||
        lower.contains('golf') ||
        lower.contains('tennis') ||
        lower.contains('skating') ||
        lower.contains('bike') ||
        lower.contains('cycle') ||
        lower.contains('kayak') ||
        lower.contains('adventure')) {
      keywords.add('sports centre');
    }

    // Spa/Wellness keywords (expanded)
    if (lower.contains('spa') ||
        lower.contains('wellness') ||
        lower.contains('massage') ||
        lower.contains('yoga') ||
        lower.contains('relax') ||
        lower.contains('meditation') ||
        lower.contains('sauna') ||
        lower.contains('hot spring') ||
        lower.contains('retreat')) {
      keywords.add('spa');
    }

    // Coffee/Cafe keywords (expanded)
    if (lower.contains('coffee') ||
        lower.contains('cafe') ||
        lower.contains('café') ||
        lower.contains('tea') ||
        lower.contains('espresso') ||
        lower.contains('cappuccino') ||
        lower.contains('latte') ||
        lower.contains('bakery') ||
        lower.contains('pastry')) {
      keywords.add('cafe');
    }

    // Shopping keywords (new)
    if (lower.contains('shop') ||
        lower.contains('store') ||
        lower.contains('market') ||
        lower.contains('boutique') ||
        lower.contains('mall') ||
        lower.contains('vintage') ||
        lower.contains('antique')) {
      keywords.add('shop');
    }

    // Bookstore/Library keywords (new)
    if (lower.contains('book') ||
        lower.contains('library') ||
        lower.contains('reading') ||
        lower.contains('literary')) {
      keywords.add('library');
    }

    return keywords;
  }

  Future<List<Map<String, dynamic>>> getPlaces(String suggestion,
      String location, String price, String dateCategory) async {
    print(
        '🔍 Searching venues for: "$suggestion" in $location with budget: $price');

    // Extract venue types from date description
    final venueTypes = _extractVenueTypes(suggestion);
    print('📍 Detected venue types: $venueTypes');

    // Collect all venues from different searches
    final allVenues = <Map<String, dynamic>>[];
    final seenIds = <String>{};

    // Search for each venue type
    for (final venueType in venueTypes.isEmpty ? ['restaurant'] : venueTypes) {
      try {
        final venues = await _searchOSM(venueType, location);

        // Deduplicate results
        for (final venue in venues) {
          final id = venue['id'];
          if (!seenIds.contains(id)) {
            seenIds.add(id);
            allVenues.add(venue);
          }
        }
      } catch (e) {
        print('⚠️ Error searching for $venueType: $e');
      }
    }

    // If no results from keyword search, try broader search with title words
    if (allVenues.isEmpty && venueTypes.isEmpty) {
      final words = suggestion.split(' ').take(2).join(' ');
      print('📝 Trying fallback search with: "$words"');
      try {
        final venues = await _searchOSM(words, location);
        allVenues.addAll(venues);
      } catch (e) {
        print('⚠️ Fallback search failed: $e');
      }
    }

    // Score and sort venues by relevance
    final scoredVenues = allVenues.map((venue) {
      venue['score'] = _calculateRelevanceScore(
        venue,
        suggestion,
        venueTypes,
        dateCategory,
      );
      return venue;
    }).toList();

    // Sort by score (highest first)
    scoredVenues
        .sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    print('✅ Found ${scoredVenues.length} venues from OpenStreetMap');
    return scoredVenues.take(20).toList();
  }

  /// Search OpenStreetMap for a specific venue type
  Future<List<Map<String, dynamic>>> _searchOSM(
      String query, String location) async {
    // Build OSM search URL - combine query with location in free-form search
    final searchQuery = '$query, $location';
    final url = Uri.parse(
        '$baseUrl/search?q=${Uri.encodeComponent(searchQuery)}&format=json&limit=30&addressdetails=1');

    // OSM requires 1 second delay between requests
    await Future.delayed(const Duration(milliseconds: 1100));

    final response = await http.get(
      url,
      headers: {
        'User-Agent': userAgent,
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> results = json.decode(response.body);

      // Parse and filter OSM results
      final venues = results
          .map((place) => _parseOSMPlace(place, [query]))
          .where((place) => place != null)
          .where((place) => _isValidVenue(place!))
          .cast<Map<String, dynamic>>()
          .toList();

      return venues;
    } else {
      throw Exception('Failed to load places: ${response.body}');
    }
  }

  /// Check if venue is a valid place (not a street, region, etc.)
  bool _isValidVenue(Map<String, dynamic> place) {
    final type = (place['category'] as String).toLowerCase();

    // Filter out non-venue types
    final invalidTypes = [
      'administrative',
      'boundary',
      'highway',
      'road',
      'street',
      'place',
      'city',
      'town',
      'village',
      'suburb',
      'neighbourhood',
      'region',
      'state',
      'country',
    ];

    return !invalidTypes.any((invalid) => type.contains(invalid));
  }

  /// Calculate relevance score for a venue
  int _calculateRelevanceScore(
    Map<String, dynamic> venue,
    String suggestion,
    List<String> venueTypes,
    String dateCategory,
  ) {
    int score = 50; // Base score

    final name = (venue['name'] as String).toLowerCase();
    final category = (venue['category'] as String).toLowerCase();
    final lowerSuggestion = suggestion.toLowerCase();

    // Boost score if name matches suggestion keywords
    final suggestionWords = lowerSuggestion.split(' ');
    for (final word in suggestionWords) {
      if (word.length > 3 && name.contains(word)) {
        score += 15;
      }
    }

    // Boost score if category matches venue types
    for (final venueType in venueTypes) {
      if (category.contains(venueType.toLowerCase())) {
        score += 20;
      }
    }

    // Boost specific venue types
    if (category.contains('restaurant') ||
        category.contains('cafe') ||
        category.contains('bar')) {
      score += 10; // Popular date venues
    }

    if (category.contains('museum') ||
        category.contains('gallery') ||
        category.contains('park')) {
      score += 10; // Cultural and outdoor venues
    }

    // Penalty for generic names
    if (name.length < 5 ||
        name.contains('unnamed') ||
        name.contains('untitled')) {
      score -= 20;
    }

    return score.clamp(0, 100);
  }

  /// Parse OpenStreetMap place to match expected format
  Map<String, dynamic>? _parseOSMPlace(
      Map<String, dynamic> place, List<String> venueTypes) {
    try {
      final address = place['address'] as Map<String, dynamic>?;
      final displayName = place['display_name'] as String?;

      // Extract name from display name (first part before comma)
      String name = displayName?.split(',').first ?? 'Unknown Place';

      // Build readable address
      String fullAddress = '';
      if (address != null) {
        final parts = <String>[];
        if (address['house_number'] != null) parts.add(address['house_number']);
        if (address['road'] != null) parts.add(address['road']);
        if (address['city'] != null) parts.add(address['city']);
        if (address['state'] != null) parts.add(address['state']);
        fullAddress = parts.join(', ');
      }
      if (fullAddress.isEmpty)
        fullAddress = displayName ?? 'Address unavailable';

      // Extract OSM type and ID for proper lookup
      final osmType = place['osm_type'] ?? 'node';
      final osmId = place['osm_id']?.toString() ?? place['place_id'].toString();

      return {
        'id': place['place_id'].toString(),
        'osm_type': osmType,
        'osm_id': osmId,
        'name': name,
        'address': fullAddress,
        'category': place['type'] ?? 'Place',
        'price': '\$\$', // OSM doesn't provide price info
        'lat': double.tryParse(place['lat']?.toString() ?? '0') ?? 0.0,
        'lon': double.tryParse(place['lon']?.toString() ?? '0') ?? 0.0,
        'score': 50, // Default score
      };
    } catch (e) {
      print('Error parsing OSM place: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> getPlaceDetails(dynamic venueData) async {
    // Extract OSM type and ID from venue object
    String osmType = venueData['osm_type'] ?? 'node';
    String osmId = venueData['osm_id'] ?? venueData['id'];

    // Determine type prefix (N=node, W=way, R=relation)
    String typePrefix = osmType.toLowerCase().startsWith('n')
        ? 'N'
        : osmType.toLowerCase().startsWith('w')
            ? 'W'
            : 'R';

    // OSM lookup by osm_type and osm_id
    final url = Uri.parse(
        '$baseUrl/lookup?osm_ids=$typePrefix$osmId&format=json&addressdetails=1&extratags=1');

    try {
      // OSM requires 1 second delay between requests
      await Future.delayed(const Duration(milliseconds: 1100));

      final response = await http.get(
        url,
        headers: {
          'User-Agent': userAgent,
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isNotEmpty) {
          return _parsePlaceDetails(data[0]);
        } else {
          // Fallback to basic venue info if lookup fails
          print('⚠️ OSM lookup failed, using basic venue data');
          return _createBasicPlaceDetails(venueData);
        }
      } else {
        // Fallback to basic venue info on API error
        print('⚠️ OSM API error, using basic venue data');
        return _createBasicPlaceDetails(venueData);
      }
    } catch (e) {
      print('Error in getPlaceDetails: $e, falling back to basic data');
      return _createBasicPlaceDetails(venueData);
    }
  }

  Map<String, dynamic> _parsePlaceDetails(Map<String, dynamic> data) {
    final extratags = data['extratags'] as Map<String, dynamic>?;
    final displayName = data['display_name'] as String?;

    String name = displayName?.split(',').first ?? 'Unknown Place';
    String fullAddress = displayName ?? 'Address unavailable';

    return {
      'id': data['place_id']?.toString() ?? data['fsq_id']?.toString() ?? '',
      'name': data['name'] ?? name,
      'description': extratags?['description'] ??
          data['description'] ??
          'No description available',
      'address': fullAddress,
      'category': data['type'] ?? data['category'] ?? 'Place',
      'photos': <String>[], // OSM doesn't provide photos via API
      'price': data['price'] != null ? '\$' * data['price'] : '\$\$',
      'rating': data['rating']?.toDouble() ?? 0.0,
      'website': extratags?['website'] ??
          extratags?['contact:website'] ??
          data['website'] ??
          'N/A',
      'phone': extratags?['phone'] ??
          extratags?['contact:phone'] ??
          data['tel'] ??
          'N/A',
      'lat': double.tryParse(data['lat']?.toString() ?? '0') ?? 0.0,
      'lon': double.tryParse(data['lon']?.toString() ?? '0') ?? 0.0,
    };
  }

  /// Create basic place details from venue data when OSM lookup fails
  Map<String, dynamic> _createBasicPlaceDetails(
      Map<String, dynamic> venueData) {
    return {
      'id': venueData['id'] ?? '',
      'name': venueData['name'] ?? 'Unknown Place',
      'description': 'No description available',
      'address': venueData['address'] ??
          venueData['vicinity'] ??
          'Address unavailable',
      'category': venueData['category'] ?? 'Place',
      'photos': <String>[],
      'price': '\$\$',
      'rating': 0.0,
      'website': 'N/A',
      'phone': 'N/A',
      'lat': venueData['lat'] ?? 0.0,
      'lon': venueData['lon'] ?? 0.0,
    };
  }
}
