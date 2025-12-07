# Places Screen Integration Plan

## Current Situation

### OLD System Files (To Be Repurposed):
- **places_screen.dart** - Shows Foursquare venues for date suggestions
- **place_details_screen.dart** - Shows venue details with photos, address, hours
- **places_service.dart** - Foursquare API integration
- **details_screen.dart** - City/price input (OLD flow)
- **results_screen.dart** - OLD questionnaire results (being replaced)

### NEW System Files (Current):
- **location_selection_screen.dart** - GPS + manual city selection (Phase 9)
- **favorites_selection_screen.dart** - Pick 3 favorites (Phase 10)
- **match_results_screen.dart** - AI matching results (Phase 10)

---

## Decision: KEEP and REPURPOSE

### Recommendation: **Keep places_screen.dart and place_details_screen.dart**

**Why Keep Them:**
1. ✅ Foursquare venue discovery is **valuable functionality**
2. ✅ Shows real venues with photos, reviews, addresses
3. ✅ Users will want to find actual places for their dates
4. ✅ Different purpose than location_selection_screen

**Key Differences:**

| Screen | Purpose | Usage |
|--------|---------|-------|
| **location_selection_screen** | Choose date **location/city** | Phase 9 - Before questionnaire |
| **places_screen** | Find specific **venues** in that city | After matching - Implementation phase |

---

## Integration Plan

### Phase 11+: Add Venue Discovery to Match Results

After partners get their matched date, they should be able to:

1. **See the matched date** (current - Phase 10)
2. **Pick a time** (Phase 11 - time negotiation)
3. **Find actual venues** (NEW - integrate places_screen)
4. **Confirm the date** (Phase 11 - confirmed date)

### Implementation Steps:

#### 1. Add "Find Venues" Button to MatchResultsScreen
```dart
// In match_results_screen.dart, after showing the matched date:

ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlacesScreen(
          suggestion: matchedDate['title'],
          priceRange: matchedDate['estimatedCost'], // Parse from "$$$"
          city: dateRequest.location ?? 'Unknown',
          dateCategory: 'date', // Or extract from activities
        ),
      ),
    );
  },
  child: Text('Find Venues for This Date'),
)
```

#### 2. Update PlacesScreen to Work with New Flow
- Remove dependency on old details_screen
- Accept location from DateRequestModel
- Show results based on matched date suggestion

#### 3. Add Venue Selection to DateRequestModel
```dart
// Add to DateRequestModel:
final Map<String, dynamic>? selectedVenue; // Foursquare place details
```

#### 4. Allow Saving Venue to Date Request
```dart
// In PlacesScreen or PlaceDetailsScreen:
ElevatedButton(
  onPressed: () async {
    await dateRequestService.saveSelectedVenue(
      dateRequestId: widget.dateRequestId,
      venue: {
        'id': placeDetails['id'],
        'name': placeDetails['name'],
        'address': placeDetails['address'],
        'photos': placeDetails['photos'],
      },
    );
    Navigator.pop(context); // Return to match results
  },
  child: Text('Choose This Venue'),
)
```

---

## Files to Remove (OLD Flow Only)

### Can Be Removed Now:
- ❌ **details_screen.dart** - Replaced by location_selection_screen.dart
- ❌ **results_screen.dart** - Replaced by favorites_selection_screen.dart + match_results_screen.dart
- ❌ **questionnaire_screen.dart** (if exists in old form) - Replaced by new questionnaire flow

These are from the OLD Gemini-based architecture and are no longer needed.

### Must Keep:
- ✅ **places_screen.dart** - Will be integrated into Phase 11+
- ✅ **place_details_screen.dart** - Shows venue details
- ✅ **places_service.dart** - Foursquare API integration

---

## Updated User Flow (with Places Integration)

### Current Flow (Phases 1-10):
1. Partners connect
2. Create date request
3. Select location (city)
4. Fill questionnaire
5. AI generates 5 suggestions
6. Both select 3 favorites
7. AI matches preferences
8. Display matched date

### Enhanced Flow (Phase 11+ with Venues):
9. **View matched date** ← Current end point
10. **"Find Venues" button** ← NEW
11. **PlacesScreen shows Foursquare venues** ← Repurposed
12. **Tap venue → PlaceDetailsScreen** ← Repurposed
13. **"Choose This Venue"** ← NEW
14. **Venue saved to date request** ← NEW
15. **Time negotiation with venue locked in** ← Phase 11
16. **Confirmed date with venue details** ← Phase 11

---

## Implementation Priority

### Immediate (Current Session):
1. ✅ Keep places_screen.dart, place_details_screen.dart, places_service.dart
2. ✅ Remove details_screen.dart (replaced by location_selection_screen)
3. ✅ Remove results_screen.dart (replaced by new screens)
4. ✅ Document integration plan for Phase 11+

### Phase 11 (Time Negotiation):
1. Add "Find Venues" button to MatchResultsScreen
2. Update PlacesScreen to accept dateRequestId
3. Add selectedVenue to DateRequestModel
4. Create saveSelectedVenue() in DateRequestService
5. Show venue in time negotiation UI

### Phase 12 (Polish):
1. Add venue photos to confirmed date screen
2. Add directions/maps integration
3. Add venue recommendations based on AI suggestion

---

## Summary

**Action Items:**
- ✅ **KEEP**: places_screen.dart, place_details_screen.dart, places_service.dart
- ❌ **REMOVE**: details_screen.dart, results_screen.dart
- 📋 **TODO**: Integrate PlacesScreen into Phase 11 after match results

**Rationale:**
- location_selection_screen = Choose the CITY
- places_screen = Find specific VENUES in that city
- Both serve different, complementary purposes
