import 'package:cloud_firestore/cloud_firestore.dart';

enum InvitationType {
  inApp, // User has the app, send push notification
  sms, // User not found, send SMS
  email, // Backup method
}

enum InvitationStatus {
  pending,
  sent,
  accepted,
  declined,
  expired,
}

class InvitationModel {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderPhotoURL;

  // Recipient info
  final String? recipientId; // If user exists in app
  final String? recipientPhone;
  final String? recipientEmail;

  final InvitationType type;
  final InvitationStatus status;

  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? respondedAt;

  final String? message; // Custom message from sender
  final Map<String, dynamic>? metadata;

  InvitationModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderPhotoURL,
    this.recipientId,
    this.recipientPhone,
    this.recipientEmail,
    required this.type,
    required this.status,
    required this.createdAt,
    this.expiresAt,
    this.respondedAt,
    this.message,
    this.metadata,
  });

  factory InvitationModel.create({
    required String senderId,
    required String senderName,
    String? senderPhotoURL,
    String? recipientId,
    String? recipientPhone,
    String? recipientEmail,
    required InvitationType type,
    String? message,
    int expiryDays = 7,
  }) {
    final now = DateTime.now();
    return InvitationModel(
      id: '', // Will be set by Firestore
      senderId: senderId,
      senderName: senderName,
      senderPhotoURL: senderPhotoURL,
      recipientId: recipientId,
      recipientPhone: recipientPhone,
      recipientEmail: recipientEmail,
      type: type,
      status: InvitationStatus.pending,
      createdAt: now,
      expiresAt: now.add(Duration(days: expiryDays)),
      message: message,
    );
  }

  factory InvitationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InvitationModel(
      id: doc.id,
      senderId: data['senderId'],
      senderName: data['senderName'],
      senderPhotoURL: data['senderPhotoURL'],
      recipientId: data['recipientId'],
      recipientPhone: data['recipientPhone'],
      recipientEmail: data['recipientEmail'],
      type: InvitationType.values.firstWhere(
        (e) => e.toString() == 'InvitationType.${data['type']}',
      ),
      status: InvitationStatus.values.firstWhere(
        (e) => e.toString() == 'InvitationStatus.${data['status']}',
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      expiresAt: data['expiresAt'] != null
          ? (data['expiresAt'] as Timestamp).toDate()
          : null,
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      message: data['message'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoURL': senderPhotoURL,
      'recipientId': recipientId,
      'recipientPhone': recipientPhone,
      'recipientEmail': recipientEmail,
      'type': type.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'respondedAt':
          respondedAt != null ? Timestamp.fromDate(respondedAt!) : null,
      'message': message,
      'metadata': metadata,
    };
  }

  InvitationModel copyWith({
    InvitationStatus? status,
    DateTime? respondedAt,
    String? recipientId,
    Map<String, dynamic>? metadata,
  }) {
    return InvitationModel(
      id: id,
      senderId: senderId,
      senderName: senderName,
      senderPhotoURL: senderPhotoURL,
      recipientId: recipientId ?? this.recipientId,
      recipientPhone: recipientPhone,
      recipientEmail: recipientEmail,
      type: type,
      status: status ?? this.status,
      createdAt: createdAt,
      expiresAt: expiresAt,
      respondedAt: respondedAt ?? this.respondedAt,
      message: message,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  bool get isPending => status == InvitationStatus.pending;
  bool get isAccepted => status == InvitationStatus.accepted;
  bool get isDeclined => status == InvitationStatus.declined;

  String get recipientIdentifier {
    if (recipientPhone != null) return recipientPhone!;
    if (recipientEmail != null) return recipientEmail!;
    return recipientId ?? 'Unknown';
  }
}
