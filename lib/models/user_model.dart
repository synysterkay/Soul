import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final List<String> interests;
  final Map<String, dynamic> preferences;
  final List<String> partnerIds; // List of partner UIDs
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProfileComplete;
  final String? currentCity;
  final Map<String, dynamic>? locationCoords; // {lat, lng}

  UserModel({
    required this.uid,
    required this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    this.interests = const [],
    this.preferences = const {},
    this.partnerIds = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isProfileComplete = false,
    this.currentCity,
    this.locationCoords,
  });

  // Create from Firebase Auth User
  factory UserModel.fromAuthUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    String? phoneNumber,
  }) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      phoneNumber: phoneNumber,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final now = DateTime.now();
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      displayName: data['displayName'],
      photoURL: data['photoURL'],
      interests: List<String>.from(data['interests'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      partnerIds: List<String>.from(data['partnerIds'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : now,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : now,
      isProfileComplete: data['isProfileComplete'] ?? false,
      currentCity: data['currentCity'],
      locationCoords: data['locationCoords'] != null
          ? Map<String, dynamic>.from(data['locationCoords'])
          : null,
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoURL': photoURL,
      'interests': interests,
      'preferences': preferences,
      'partnerIds': partnerIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isProfileComplete': isProfileComplete,
      'currentCity': currentCity,
      'locationCoords': locationCoords,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    List<String>? interests,
    Map<String, dynamic>? preferences,
    List<String>? partnerIds,
    DateTime? updatedAt,
    bool? isProfileComplete,
    String? currentCity,
    Map<String, dynamic>? locationCoords,
  }) {
    return UserModel(
      uid: uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      interests: interests ?? this.interests,
      preferences: preferences ?? this.preferences,
      partnerIds: partnerIds ?? this.partnerIds,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      currentCity: currentCity ?? this.currentCity,
      locationCoords: locationCoords ?? this.locationCoords,
    );
  }

  // Check if user has a specific partner
  bool hasPartner(String partnerId) {
    return partnerIds.contains(partnerId);
  }

  // Add partner
  UserModel addPartner(String partnerId) {
    if (hasPartner(partnerId)) return this;
    return copyWith(
      partnerIds: [...partnerIds, partnerId],
      updatedAt: DateTime.now(),
    );
  }

  // Remove partner
  UserModel removePartner(String partnerId) {
    return copyWith(
      partnerIds: partnerIds.where((id) => id != partnerId).toList(),
      updatedAt: DateTime.now(),
    );
  }
}
