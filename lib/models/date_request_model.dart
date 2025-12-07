import 'package:cloud_firestore/cloud_firestore.dart';

enum DateRequestMode {
  collaborative, // Both answer questionnaire together in real-time
  surprise, // One plans, other doesn't know
  lastMinute, // Quick decision needed
}

enum DateRequestStatus {
  pending, // Created, waiting for partner response
  questionnaireFilled, // Both filled questionnaires
  suggestionsGenerated, // AI generated date ideas
  selecting, // Partners selecting favorites
  matched, // AI matched or compromised
  timeNegotiating, // Discussing when
  confirmed, // Date is set
  completed, // Date happened
  cancelled, // Cancelled by either party
}

class DateRequestModel {
  final String id;
  final String initiatorId;
  final String partnerId;
  final DateRequestMode mode;
  final DateRequestStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Questionnaire responses
  final Map<String, dynamic>? initiatorAnswers;
  final Map<String, dynamic>? partnerAnswers;

  // AI-generated suggestions
  final List<Map<String, dynamic>>? suggestions;

  // User selections (full favorite suggestion objects)
  final List<Map<String, dynamic>>? initiatorFavorites;
  final List<Map<String, dynamic>>? partnerFavorites;

  // Matched date
  final Map<String, dynamic>? selectedDate;

  // Time negotiation
  final List<Map<String, dynamic>>? proposedTimes;
  final DateTime? confirmedTime;

  // Location
  final String? location;
  final Map<String, dynamic>? locationCoords;

  // Metadata
  final Map<String, dynamic>? metadata;

  DateRequestModel({
    required this.id,
    required this.initiatorId,
    required this.partnerId,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.initiatorAnswers,
    this.partnerAnswers,
    this.suggestions,
    this.initiatorFavorites,
    this.partnerFavorites,
    this.selectedDate,
    this.proposedTimes,
    this.confirmedTime,
    this.location,
    this.locationCoords,
    this.metadata,
  });

  factory DateRequestModel.create({
    required String initiatorId,
    required String partnerId,
    required DateRequestMode mode,
    String? location,
    Map<String, dynamic>? locationCoords,
  }) {
    final now = DateTime.now();
    return DateRequestModel(
      id: '', // Will be set by Firestore
      initiatorId: initiatorId,
      partnerId: partnerId,
      mode: mode,
      status: DateRequestStatus.pending,
      createdAt: now,
      updatedAt: now,
      location: location,
      locationCoords: locationCoords,
    );
  }

  factory DateRequestModel.fromFirestore(DocumentSnapshot doc) {
    print('=== DateRequestModel.fromFirestore ===');
    print('Doc ID: ${doc.id}');

    final data = doc.data() as Map<String, dynamic>;
    print('Raw data keys: ${data.keys.toList()}');

    try {
      print(
          'Parsing initiatorAnswers: ${data['initiatorAnswers']?.runtimeType}');
      final initiatorAnswers = data['initiatorAnswers'] != null
          ? (data['initiatorAnswers'] is Map
              ? Map<String, dynamic>.from(data['initiatorAnswers'] as Map)
              : null)
          : null;

      print('Parsing partnerAnswers: ${data['partnerAnswers']?.runtimeType}');
      final partnerAnswers = data['partnerAnswers'] != null
          ? (data['partnerAnswers'] is Map
              ? Map<String, dynamic>.from(data['partnerAnswers'] as Map)
              : null)
          : null;

      print('initiatorAnswers parsed: ${initiatorAnswers != null}');
      print('partnerAnswers parsed: ${partnerAnswers != null}');

      return DateRequestModel(
        id: doc.id,
        initiatorId: data['initiatorId'],
        partnerId: data['partnerId'],
        mode: DateRequestMode.values.firstWhere(
          (e) => e.toString() == 'DateRequestMode.${data['mode']}',
        ),
        status: DateRequestStatus.values.firstWhere(
          (e) => e.toString() == 'DateRequestStatus.${data['status']}',
        ),
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] as Timestamp).toDate()
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] as Timestamp).toDate()
            : DateTime.now(),
        initiatorAnswers: initiatorAnswers,
        partnerAnswers: partnerAnswers,
        suggestions: (data['aiSuggestions'] ?? data['suggestions']) != null
            ? List<Map<String, dynamic>>.from(
                ((data['aiSuggestions'] ?? data['suggestions']) as List)
                    .where((s) => s != null)
                    .map((s) => Map<String, dynamic>.from(s as Map)),
              )
            : null,
        initiatorFavorites: data['initiatorFavorites'] != null
            ? List<Map<String, dynamic>>.from(
                (data['initiatorFavorites'] as List)
                    .where((f) => f != null)
                    .map((f) => Map<String, dynamic>.from(f as Map)),
              )
            : null,
        partnerFavorites: data['partnerFavorites'] != null
            ? List<Map<String, dynamic>>.from(
                (data['partnerFavorites'] as List)
                    .where((f) => f != null)
                    .map((f) => Map<String, dynamic>.from(f as Map)),
              )
            : null,
        selectedDate: data['selectedDate'] != null
            ? Map<String, dynamic>.from(data['selectedDate'] as Map)
            : null,
        proposedTimes: data['proposedTimes'] != null
            ? List<Map<String, dynamic>>.from(
                (data['proposedTimes'] as List)
                    .where((t) => t != null)
                    .map((t) => Map<String, dynamic>.from(t as Map)),
              )
            : null,
        confirmedTime: data['confirmedTime'] != null
            ? (data['confirmedTime'] as Timestamp).toDate()
            : null,
        location: data['location'],
        locationCoords: data['locationCoords'] != null
            ? (data['locationCoords'] is Map
                ? Map<String, dynamic>.from(data['locationCoords'] as Map)
                : null)
            : null,
        metadata: data['metadata'] != null
            ? (data['metadata'] is Map
                ? Map<String, dynamic>.from(data['metadata'] as Map)
                : null)
            : null,
      );
    } catch (e, stackTrace) {
      print('!!! ERROR in DateRequestModel.fromFirestore !!!');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'initiatorId': initiatorId,
      'partnerId': partnerId,
      'mode': mode.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'initiatorAnswers': initiatorAnswers,
      'partnerAnswers': partnerAnswers,
      'suggestions': suggestions,
      'initiatorFavorites': initiatorFavorites,
      'partnerFavorites': partnerFavorites,
      'selectedDate': selectedDate,
      'proposedTimes': proposedTimes,
      'confirmedTime':
          confirmedTime != null ? Timestamp.fromDate(confirmedTime!) : null,
      'location': location,
      'locationCoords': locationCoords,
      'metadata': metadata,
    };
  }

  DateRequestModel copyWith({
    DateRequestStatus? status,
    Map<String, dynamic>? initiatorAnswers,
    Map<String, dynamic>? partnerAnswers,
    List<Map<String, dynamic>>? suggestions,
    List<Map<String, dynamic>>? initiatorFavorites,
    List<Map<String, dynamic>>? partnerFavorites,
    Map<String, dynamic>? selectedDate,
    List<Map<String, dynamic>>? proposedTimes,
    DateTime? confirmedTime,
    String? location,
    Map<String, dynamic>? locationCoords,
    Map<String, dynamic>? metadata,
  }) {
    return DateRequestModel(
      id: id,
      initiatorId: initiatorId,
      partnerId: partnerId,
      mode: mode,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      initiatorAnswers: initiatorAnswers ?? this.initiatorAnswers,
      partnerAnswers: partnerAnswers ?? this.partnerAnswers,
      suggestions: suggestions ?? this.suggestions,
      initiatorFavorites: initiatorFavorites ?? this.initiatorFavorites,
      partnerFavorites: partnerFavorites ?? this.partnerFavorites,
      selectedDate: selectedDate ?? this.selectedDate,
      proposedTimes: proposedTimes ?? this.proposedTimes,
      confirmedTime: confirmedTime ?? this.confirmedTime,
      location: location ?? this.location,
      locationCoords: locationCoords ?? this.locationCoords,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isSurpriseMode => mode == DateRequestMode.surprise;
  bool get isLastMinute => mode == DateRequestMode.lastMinute;
  bool get isCollaborative => mode == DateRequestMode.collaborative;

  bool get canGenerateSuggestions =>
      initiatorAnswers != null &&
      (mode == DateRequestMode.surprise || partnerAnswers != null);

  bool get canSelectFavorites => suggestions != null && suggestions!.isNotEmpty;

  bool get readyForMatching =>
      initiatorFavorites != null &&
      initiatorFavorites!.length >= 3 &&
      (mode == DateRequestMode.surprise ||
          (partnerFavorites != null && partnerFavorites!.length >= 3));
}
