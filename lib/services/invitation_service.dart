import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation_model.dart';
import '../models/user_model.dart';

class InvitationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Send invitation to an existing app user (in-app notification)
  Future<InvitationModel> sendInAppInvitation({
    required String senderId,
    required String senderName,
    String? senderPhotoURL,
    required String recipientId,
    String? message,
  }) async {
    try {
      // Create invitation
      final invitation = InvitationModel.create(
        senderId: senderId,
        senderName: senderName,
        senderPhotoURL: senderPhotoURL,
        recipientId: recipientId,
        type: InvitationType.inApp,
        message: message,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('invitations').add(
            invitation.toFirestore(),
          );

      // Update invitation with ID
      final savedInvitation = invitation.copyWith(
        metadata: {'invitationId': docRef.id},
      );

      await docRef.update({'id': docRef.id});

      // Send push notification
      await _sendPushNotification(
        recipientId: recipientId,
        title: 'New Partner Request',
        body: '$senderName wants to be your partner on Soul Plan!',
        data: {
          'type': 'partner_invitation',
          'invitationId': docRef.id,
          'senderId': senderId,
        },
      );

      return savedInvitation.copyWith(
        metadata: {'invitationId': docRef.id},
      );
    } catch (e) {
      print('Error sending in-app invitation: $e');
      rethrow;
    }
  }

  /// Send invitation via SMS (for users not on the app)
  Future<InvitationModel> sendSmsInvitation({
    required String senderId,
    required String senderName,
    String? senderPhotoURL,
    required String recipientPhone,
    String? message,
  }) async {
    try {
      // Create invitation
      final invitation = InvitationModel.create(
        senderId: senderId,
        senderName: senderName,
        senderPhotoURL: senderPhotoURL,
        recipientPhone: recipientPhone,
        type: InvitationType.sms,
        message: message,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('invitations').add(
            invitation.toFirestore(),
          );

      await docRef.update({'id': docRef.id});

      // TODO: Integrate with SMS service (Twilio, AWS SNS, etc.)
      // For now, this would need to be implemented based on your SMS provider
      print('SMS invitation would be sent to: $recipientPhone');

      return invitation.copyWith(
        metadata: {'invitationId': docRef.id},
      );
    } catch (e) {
      print('Error sending SMS invitation: $e');
      rethrow;
    }
  }

  /// Send invitation via email (backup method)
  Future<InvitationModel> sendEmailInvitation({
    required String senderId,
    required String senderName,
    String? senderPhotoURL,
    required String recipientEmail,
    String? message,
  }) async {
    try {
      // Create invitation
      final invitation = InvitationModel.create(
        senderId: senderId,
        senderName: senderName,
        senderPhotoURL: senderPhotoURL,
        recipientEmail: recipientEmail,
        type: InvitationType.email,
        message: message,
      );

      // Save to Firestore
      final docRef = await _firestore.collection('invitations').add(
            invitation.toFirestore(),
          );

      await docRef.update({'id': docRef.id});

      // TODO: Integrate with email service (SendGrid, AWS SES, etc.)
      print('Email invitation would be sent to: $recipientEmail');

      return invitation.copyWith(
        metadata: {'invitationId': docRef.id},
      );
    } catch (e) {
      print('Error sending email invitation: $e');
      rethrow;
    }
  }

  /// Get pending invitations for a user
  Stream<List<InvitationModel>> getPendingInvitations(String userId) {
    return _firestore
        .collection('invitations')
        .where('recipientId', isEqualTo: userId)
        .where('status', isEqualTo: InvitationStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvitationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get sent invitations by a user
  Stream<List<InvitationModel>> getSentInvitations(String userId) {
    return _firestore
        .collection('invitations')
        .where('senderId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => InvitationModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Accept invitation
  Future<void> acceptInvitation(String invitationId, String userId) async {
    try {
      final invitationRef =
          _firestore.collection('invitations').doc(invitationId);
      final invitationDoc = await invitationRef.get();

      if (!invitationDoc.exists) {
        throw Exception('Invitation not found');
      }

      final invitation = InvitationModel.fromFirestore(invitationDoc);

      // Update invitation status
      await invitationRef.update({
        'status': InvitationStatus.accepted.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Add partner relationship for both users
      final batch = _firestore.batch();

      // Add sender to recipient's partners
      final recipientRef = _firestore.collection('users').doc(userId);
      batch.update(recipientRef, {
        'partnerIds': FieldValue.arrayUnion([invitation.senderId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add recipient to sender's partners
      final senderRef = _firestore.collection('users').doc(invitation.senderId);
      batch.update(senderRef, {
        'partnerIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Send notification to sender
      await _sendPushNotification(
        recipientId: invitation.senderId,
        title: 'Invitation Accepted!',
        body: 'Your partner request was accepted',
        data: {
          'type': 'invitation_accepted',
          'invitationId': invitationId,
          'partnerId': userId,
        },
      );
    } catch (e) {
      print('Error accepting invitation: $e');
      rethrow;
    }
  }

  /// Decline invitation
  Future<void> declineInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).update({
        'status': InvitationStatus.declined.name,
        'respondedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error declining invitation: $e');
      rethrow;
    }
  }

  /// Cancel sent invitation
  Future<void> cancelInvitation(String invitationId) async {
    try {
      await _firestore.collection('invitations').doc(invitationId).delete();
    } catch (e) {
      print('Error cancelling invitation: $e');
      rethrow;
    }
  }

  /// Send push notification
  Future<void> _sendPushNotification({
    required String recipientId,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // Get recipient's FCM token from Firestore
      final userDoc =
          await _firestore.collection('users').doc(recipientId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        final fcmToken = userData?['fcmToken'] as String?;

        if (fcmToken != null) {
          // TODO: Implement FCM admin SDK server-side to send notifications
          // For now, this is a placeholder
          print('Would send notification to token: $fcmToken');
          print('Title: $title');
          print('Body: $body');
          print('Data: $data');
        }
      }
    } catch (e) {
      print('Error sending push notification: $e');
      // Don't rethrow - notification failure shouldn't break the flow
    }
  }

  /// Initialize FCM for receiving notifications
  /// DEPRECATED: Now using OneSignal for notifications
  Future<void> initializeFCM(String userId) async {
    print('⚠️ initializeFCM is deprecated - using OneSignal instead');
    // This method is kept for backward compatibility but does nothing
    // OneSignal handles all push notifications now
  }
}
