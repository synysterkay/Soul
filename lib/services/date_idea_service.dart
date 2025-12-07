class DateIdeaService {
  static const Map<String, List<String>> dateCategories = {
    "standup_comedy": ["comedy", "standup", "laugh", "humor", "comedian"],
    "movie": ["movie", "cinema", "film", "theater", "screening", "blockbuster"],
    "dinner": ["dinner", "restaurant", "eat", "cuisine", "food", "dining", "culinary", "gastronomy"],
    "outdoor_activity": ["park", "hike", "beach", "outdoor", "nature", "picnic", "garden", "trail", "camping"],
    "sports": ["sports", "game", "match", "stadium", "arena", "athletic", "tournament", "league"],
    "adventure": ["go-kart", "go karting", "laser tag", "paintball", "escape room", "adventure", "quest", "challenge"],
    "cultural": ["museum", "art gallery", "exhibition", "concert", "opera", "theater", "culture", "heritage", "history"],
    "relaxation": ["spa", "massage", "yoga", "meditation", "wellness", "relax", "unwind", "chill"],
    "educational": ["workshop", "class", "lecture", "learning", "seminar", "course", "study", "education"],
    "nightlife": ["bar", "club", "dance", "nightclub", "pub", "lounge", "disco"],
    "music": ["live music", "concert", "gig", "festival", "band", "performance", "acoustic", "DJ"],
    "gaming": ["arcade", "video games", "board games", "puzzle", "gaming", "e-sports", "lan party"],
    "water_activity": ["swimming", "kayaking", "surfing", "boat", "beach", "paddle", "sail", "waterpark"],
    "fitness": ["gym", "workout", "exercise", "fitness class", "training", "aerobics", "crossfit"],
    "shopping": ["mall", "shopping center", "boutique", "market", "store", "shop", "retail"],
    "animal_related": ["zoo", "aquarium", "pet cafe", "animal sanctuary", "wildlife", "farm", "petting zoo"],
    "adrenaline": ["bungee jumping", "skydiving", "rock climbing", "zip lining", "paragliding", "racing"],
    "romantic": ["sunset watching", "stargazing", "couples massage", "romantic walk", "candlelit dinner"],
    "creative": ["painting class", "pottery", "crafting", "DIY workshop", "art class", "sculpture", "photography"],
    "technology": ["vr", "virtual reality", "tech", "technology", "coding", "robotics", "augmented reality", "ar", "3d printing", "ai"],
    "food_experience": ["cooking class", "wine tasting", "food tour", "brewery tour", "mixology", "baking"],
    "dance": ["dance class", "ballroom", "salsa", "tango", "ballet", "hip-hop"],
    "spiritual": ["temple", "church", "meditation center", "retreat", "spiritual workshop"],
    "literary": ["book club", "poetry reading", "library event", "author meet", "writing workshop"],
    "seasonal": ["ice skating", "pumpkin patch", "christmas market", "spring festival", "summer fair"],
    "scenic": ["sightseeing", "tour", "landmark", "viewpoint", "observation deck"],
    "wellness": ["health retreat", "nutrition workshop", "mindfulness session", "detox program"],
    "social_cause": ["volunteer", "charity event", "fundraiser", "community service"],
    "transportation": ["train ride", "hot air balloon", "helicopter tour", "cruise", "bike tour"],
    "mystery": ["murder mystery", "detective game", "treasure hunt", "scavenger hunt"],
    "yoga": ["yoga", "meditation", "mindfulness"],
    "go_kart": ["go-kart", "go karting", "racing"],
    "hiking": ["hiking", "trail", "trekking", "mountain"],
    "cinema": ["cinema", "movie theater", "film screening"],
    "scenic_activity": ["sunset", "sunrise", "stargazing", "view", "lookout", "scenic"],
    "walking": ["walk", "stroll", "promenade"],
  };
  static Map<String, List<String>> categoryMapping = {
    'dateIdea_adventurePark': ['adventure', 'outdoor_activity'],
    'dateIdea_danceClass': ['dance', 'educational'],
    'dateIdea_rockClimbing': ['adrenaline', 'sports'],
    'dateIdea_bikeRidePicnic': ['outdoor_activity', 'romantic'],
    'dateIdea_escapeRoom': ['adventure', 'mystery'],
    'dateIdea_cookingClass': ['food_experience', 'educational'],
    'dateIdea_artGallery': ['cultural', 'creative'],
    'dateIdea_sunsetHike': ['hiking', 'scenic_activity', 'romantic'],
    'dateIdea_kayaking': ['water_activity', 'adventure'],
    'dateIdea_boardGameCafe': ['gaming', 'relaxation'],
    'dateIdea_stargazingPicnic': ['romantic', 'scenic_activity'],
    'dateIdea_spaDayy': ['relaxation', 'wellness'],
    'dateIdea_wineTasting': ['food_experience'],
    'dateIdea_bookstoreCafe': ['literary', 'relaxation'],
    'dateIdea_yoga': ['yoga', 'wellness'],
    'dateIdea_meditation': ['relaxation', 'spiritual'],
    'dateIdea_natureWalk': ['walking', 'outdoor_activity'],
    'dateIdea_couplesMassage': ['relaxation', 'romantic'],
    'dateIdea_musicConcert': ['music', 'nightlife'],
    'dateIdea_potteryClass': ['creative', 'educational'],
    'dateIdea_mysteryDate': ['mystery', 'adventure'],
    'dateIdea_foodTour': ['food_experience', 'cultural'],
    'dateIdea_amusementPark': ['adventure', 'adrenaline'],
    'dateIdea_comedyShow': ['standup_comedy', 'nightlife'],
    'dateIdea_karaoke': ['music', 'nightlife'],
    'dateIdea_movieMarathon': ['movie', 'relaxation'],
    'dateIdea_scenicDrive': ['scenic', 'transportation'],
    'dateIdea_relaxingPicnic': ['outdoor_activity', 'relaxation'],
    'dateIdea_bookReading': ['literary', 'relaxation'],
    'dateIdea_stargazing': ['romantic', 'scenic_activity'],
    'dateIdea_newRestaurant': ['dinner', 'food_experience'],
    'dateIdea_museum': ['cultural', 'educational'],
    'dateIdea_cookingClass2': ['food_experience', 'educational'],
    'dateIdea_natureWalk2': ['walking', 'outdoor_activity'],
    'dateIdea_localEvent': ['cultural', 'social_cause']
  };

  static List<String> categorizeDateIdea(String dateIdea) {
    try {
      if (dateIdea.startsWith('dateIdea_')) {
        return categoryMapping[dateIdea] ?? ['other'];
      }

      final lowerCaseDateIdea = dateIdea.toLowerCase();
      List<String> matchedCategories = [];

      for (var entry in dateCategories.entries) {
        if (entry.value.any((keyword) => lowerCaseDateIdea.contains(keyword))) {
          matchedCategories.add(entry.key);
        }
      }

      return matchedCategories.isEmpty ? ['other'] : matchedCategories;
    } catch (e) {
      print("Error categorizing date idea '$dateIdea': $e");
      return ['other']; // Default fallback category
    }
  }

  static List<String> getRelevantPlaceTypes(List<String> categories) {
    Set<String> placeTypes = {};
    for (String category in categories) {
      placeTypes.addAll(_getPlaceTypesForCategory(category));
    }
    return placeTypes.toList();
  }

  static List<String> extractKeywords(String dateIdea) {
    if (dateIdea.startsWith('dateIdea_')) {
      final categories = categoryMapping[dateIdea] ?? ['other'];
      return categories
          .expand((category) => dateCategories[category] ?? [])
          .cast<String>()
          .toList();
    }
    final words = dateIdea.toLowerCase().split(' ');
    return words.where((word) => word.length > 3).toList();
  }


  static List<String> getPriorityPlaceTypes(String dateIdea) {
    final categories = categorizeDateIdea(dateIdea);
    final placeTypes = getRelevantPlaceTypes(categories);
    final keywords = extractKeywords(dateIdea);

    placeTypes.sort((a, b) {
      final aScore = keywords.where((k) => a.contains(k)).length;
      final bScore = keywords.where((k) => b.contains(k)).length;
      return bScore.compareTo(aScore);
    });

    return placeTypes;
  }
  static List<String> _getPlaceTypesForCategory(String category) {
    switch (category) {
      case "standup_comedy": return ["comedy_club", "theater", "entertainment_venue"];
      case "movie": return ["movie_theater", "cinema", "drive_in_theater"];
      case "dinner": return ["restaurant", "food", "cafe", "bistro", "diner"];
      case "outdoor_activity": return ["park", "trail", "beach", "garden", "campground", "nature_reserve"];
      case "sports": return ["stadium", "sports_club", "athletic_field", "gym", "recreation_center"];
      case "adventure": return ["amusement_park", "go_kart_track", "paintball_field", "escape_room", "adventure_sports_venue"];
      case "cultural": return ["museum", "art_gallery", "theater", "concert_hall", "historical_landmark"];
      case "relaxation": return ["spa", "yoga_studio", "wellness_center", "massage_clinic", "meditation_center"];
      case "educational": return ["school", "university", "library", "community_center", "learning_center"];
      case "nightlife": return ["bar", "nightclub", "pub", "lounge", "music_venue"];
      case "music": return ["music_venue", "concert_hall", "jazz_club", "record_store"];
      case "gaming": return ["arcade", "game_cafe", "lan_gaming_center", "board_game_cafe"];
      case "water_activity": return ["beach", "pool", "water_park", "marina", "aquatic_center"];
      case "fitness": return ["gym", "fitness_center", "yoga_studio", "crossfit_box", "sports_complex"];
      case "shopping": return ["mall", "shopping_center", "department_store", "boutique", "market"];
      case "animal_related": return ["zoo", "aquarium", "pet_store", "wildlife_sanctuary", "farm"];
      case "adrenaline": return ["amusement_park", "climbing_gym", "skydiving_center", "race_track", "bungee_jumping_site"];
      case "romantic": return ["park", "scenic_lookout", "beach", "restaurant", "botanical_garden"];
      case "creative": return ["art_studio", "craft_store", "workshop", "makerspace", "pottery_studio"];
      case "technology": return ["virtual_reality_center", "tech_museum", "arcade", "electronics_store", "makerspace"];
      case "food_experience": return ["cooking_school", "winery", "brewery", "food_tour_meeting_point", "culinary_institute"];
      case "dance": return ["dance_studio", "ballroom", "nightclub", "community_center"];
      case "spiritual": return ["temple", "church", "meditation_center", "spiritual_center", "retreat_center"];
      case "literary": return ["library", "bookstore", "cafe", "community_center", "university"];
      case "seasonal": return ["ice_rink", "farm", "market", "fairground", "park"];
      case "scenic": return ["scenic_lookout", "tour_meeting_point", "landmark", "observation_deck"];
      case "wellness": return ["health_resort", "spa", "fitness_center", "nutrition_center", "yoga_studio"];
      case "social_cause": return ["community_center", "non_profit_organization", "event_space", "park"];
      case "transportation": return ["train_station", "airport", "harbor", "bike_rental", "tour_meeting_point"];
      case "mystery": return ["escape_room", "theater", "event_space", "restaurant", "historical_site"];
      case "yoga": return ["yoga_studio", "fitness_center", "wellness_center", "park"];
      case "go_kart": return ["go_kart_track", "amusement_park", "recreation_center"];
      case "hiking": return ["trail", "park", "mountain", "nature_reserve"];
      case "cinema": return ["movie_theater", "cinema", "entertainment_venue"];
      case "scenic_activity": return ["scenic_lookout", "park", "beach", "mountain", "observation_deck", "nature_reserve"];
      case "walking": return ["park", "trail", "beach", "garden", "nature_reserve", "pedestrian_plaza", "waterfront"];
      default: return ["point_of_interest"];
    }
  }

  static bool isPriceSensitiveActivity(String suggestion) {
    List<String> priceInsensitiveCategories = ["walking", "scenic_activity", "outdoor_activity", "hiking"];
    List<String> categories = categorizeDateIdea(suggestion);
    return !categories.any((category) => priceInsensitiveCategories.contains(category));
  }

  static bool isMuseumOrHistoricalActivity(String suggestion) {
    List<String> museumHistoricalKeywords = ["museum", "historical", "history", "exhibit", "heritage", "cultural", "artifact"];
    return museumHistoricalKeywords.any((keyword) => suggestion.toLowerCase().contains(keyword));
  }
}
