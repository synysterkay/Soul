import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../models/date_request_model.dart';
import 'onesignal_service.dart';
import 'email_service.dart';
import 'notification_strategy_service.dart';

class DateRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OneSignalService _oneSignalService = OneSignalService();
  final EmailService _emailService = EmailService();
  final NotificationStrategyService _notificationStrategy = NotificationStrategyService();

  /// Create a new date request
  Future<DateRequestModel> createDateRequest({
    required String initiatorId,
    required String partnerId,
    required DateRequestMode mode,
    Map<String, dynamic>? initiatorAnswers,
    String? location,
    Map<String, dynamic>? locationCoords,
  }) async {
    try {
      // Create date request
      final dateRequest = DateRequestModel(
        id: '', // Will be set by Firestore
        initiatorId: initiatorId,
        partnerId: partnerId,
        mode: mode,
        status: DateRequestStatus.pending,
        initiatorAnswers: initiatorAnswers ?? {},
        partnerAnswers: {},
        location: location,
        locationCoords: locationCoords,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to Firestore
      final docRef = await _firestore.collection('dateRequests').add(
            dateRequest.toFirestore(),
          );

      // Update with ID
      await docRef.update({'id': docRef.id});

      // Get partner's info for personalization
      final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
      final partnerData = partnerDoc.data();
      final partnerEmail = partnerData?['email'] as String?;
      final partnerName = partnerData?['displayName'] as String? ?? 'there';
      
      final initiatorDoc = await _firestore.collection('users').doc(initiatorId).get();
      final initiatorData = initiatorDoc.data();
      final initiatorName = initiatorData?['displayName'] as String? ?? 'Your partner';

      // Send smart notification to partner (urgent - always send)
      await _notificationStrategy.sendSmartNotification(
        recipientId: partnerId,
        title: '💕 New Date Request!',
        body: mode == DateRequestMode.surprise
            ? '$initiatorName wants to plan a surprise date for you!'
            : '$initiatorName wants to plan a date together!',
        type: 'questionnaire_invite',
        dateRequestId: docRef.id,
        isUrgent: true,
        sendEmail: true,
      );

      // Send email to partner
      if (partnerEmail != null && partnerEmail.isNotEmpty) {
        await _emailService.sendDateRequestEmail(
          recipientEmail: partnerEmail,
          recipientName: partnerName,
          partnerName: initiatorName,
          dateRequestId: docRef.id,
        );
      }

      // Track behavior
      await _emailService.trackBehavior(
        userId: initiatorId,
        event: 'date_created',
        metadata: {'date_request_id': docRef.id, 'mode': mode.name},
      );

      // Return new instance with correct id
      return DateRequestModel(
        id: docRef.id,
        initiatorId: initiatorId,
        partnerId: partnerId,
        mode: mode,
        status: DateRequestStatus.pending,
        initiatorAnswers: initiatorAnswers ?? {},
        partnerAnswers: {},
        location: location,
        locationCoords: locationCoords,
        createdAt: dateRequest.createdAt,
        updatedAt: dateRequest.updatedAt,
      );
    } catch (e) {
      print('Error creating date request: $e');
      rethrow;
    }
  }

  /// Get active date requests for a user (as initiator or partner)
  Stream<List<DateRequestModel>> getDateRequests(String userId) {
    return _firestore
        .collection('dateRequests')
        .where('status', whereIn: [
          DateRequestStatus.pending.name,
          DateRequestStatus.questionnaireFilled.name,
          DateRequestStatus.suggestionsGenerated.name,
          DateRequestStatus.selecting.name,
          DateRequestStatus.matched.name,
          DateRequestStatus.timeNegotiating.name,
        ])
        .snapshots()
        .asyncMap((snapshot) async {
          final List<DateRequestModel> requests = [];
          for (final doc in snapshot.docs) {
            final request = DateRequestModel.fromFirestore(doc);
            // Only include if user is involved
            if (request.initiatorId == userId || request.partnerId == userId) {
              requests.add(request);
            }
          }
          return requests;
        });
  }

  /// Get completed date requests for a user
  Stream<List<DateRequestModel>> getCompletedDateRequests(String userId) {
    return _firestore
        .collection('dateRequests')
        .where('status', whereIn: [
          DateRequestStatus.confirmed.name,
          DateRequestStatus.completed.name,
        ])
        .orderBy('createdAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
          final List<DateRequestModel> requests = [];
          for (final doc in snapshot.docs) {
            final request = DateRequestModel.fromFirestore(doc);
            // Only include if user is involved
            if (request.initiatorId == userId || request.partnerId == userId) {
              requests.add(request);
            }
          }
          return requests;
        });
  }

  /// Get a specific date request
  Stream<DateRequestModel> getDateRequest(String dateRequestId) {
    return _firestore
        .collection('dateRequests')
        .doc(dateRequestId)
        .snapshots()
        .map((doc) => DateRequestModel.fromFirestore(doc));
  }

  /// Update questionnaire answers for initiator
  Future<void> updateInitiatorAnswers(
    String dateRequestId,
    Map<String, dynamic> answers,
  ) async {
    try {
      final docRef = _firestore.collection('dateRequests').doc(dateRequestId);
      await docRef.update({
        'initiatorAnswers': answers,
        'status': DateRequestStatus.questionnaireFilled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Get user info and send congratulations email
      final doc = await docRef.get();
      final request = DateRequestModel.fromFirestore(doc);
      final userDoc = await _firestore.collection('users').doc(request.initiatorId).get();
      final userData = userDoc.data();
      final userEmail = userData?['email'] as String?;
      final userName = userData?['displayName'] as String? ?? 'there';

      if (userEmail != null && userEmail.isNotEmpty) {
        await _emailService.sendQuestionnaireCompletedEmail(
          recipientEmail: userEmail,
          recipientName: userName,
        );
      }

      // Track completion
      await _emailService.trackBehavior(
        userId: request.initiatorId,
        event: 'questionnaire_completed',
        metadata: {'date_request_id': dateRequestId},
      );
    } catch (e) {
      print('Error updating initiator answers: $e');
      rethrow;
    }
  }

  /// Update questionnaire answers for partner
  Future<void> updatePartnerAnswers(
    String dateRequestId,
    Map<String, dynamic> answers,
  ) async {
    try {
      final docRef = _firestore.collection('dateRequests').doc(dateRequestId);
      final doc = await docRef.get();
      final request = DateRequestModel.fromFirestore(doc);

      // Check if both have answered to update status
      final newStatus = request.mode == DateRequestMode.collaborative &&
              (request.initiatorAnswers?.isNotEmpty ?? false)
          ? DateRequestStatus.suggestionsGenerated.name
          : DateRequestStatus.questionnaireFilled.name;

      await docRef.update({
        'partnerAnswers': answers,
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If ready to generate, notify initiator
      if (newStatus == DateRequestStatus.suggestionsGenerated.name) {
        await _notificationStrategy.sendSmartNotification(
          recipientId: request.initiatorId,
          title: '✨ Questionnaire Complete',
          body: 'Both of you have answered! Time to generate date ideas.',
          type: 'questionnaire_complete',
          dateRequestId: dateRequestId,
          isUrgent: false,
          sendEmail: false,
        );
      }
    } catch (e) {
      print('Error updating partner answers: $e');
      rethrow;
    }
  }

  /// Save AI-generated suggestions
  Future<void> saveSuggestions(
    String dateRequestId,
    List<Map<String, dynamic>> suggestions,
  ) async {
    try {
      await _firestore.collection('dateRequests').doc(dateRequestId).update({
        'aiSuggestions': suggestions,
        'status': DateRequestStatus.suggestionsGenerated.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error saving suggestions: $e');
      rethrow;
    }
  }

  /// Update proposed time
  Future<void> updateProposedTime(
    String dateRequestId,
    String userId,
    DateTime proposedTime,
  ) async {
    try {
      final docRef = _firestore.collection('dateRequests').doc(dateRequestId);
      final doc = await docRef.get();
      final request = DateRequestModel.fromFirestore(doc);

      final isInitiator = userId == request.initiatorId;
      final field = isInitiator ? 'proposedTime' : 'partnerProposedTime';

      await docRef.update({
        field: Timestamp.fromDate(proposedTime),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify the other person
      final recipientId = isInitiator ? request.partnerId : request.initiatorId;
      await _notificationStrategy.sendSmartNotification(
        recipientId: recipientId,
        title: '⏰ Time Proposed',
        body: 'Your partner proposed a time for your date!',
        type: 'time_proposed',
        dateRequestId: dateRequestId,
        isUrgent: true,
        sendEmail: true,
      );
    } catch (e) {
      print('Error updating proposed time: $e');
      rethrow;
    }
  }

  /// Update initiator's favorite selections
  Future<void> updateInitiatorFavorites(
    String dateRequestId,
    List<Map<String, dynamic>> favorites,
  ) async {
    try {
      // Get current request to check partner's favorites
      final doc =
          await _firestore.collection('dateRequests').doc(dateRequestId).get();
      final data = doc.data();
      final partnerFavorites = data?['partnerFavorites'] as List?;

      // Update initiator favorites
      await _firestore.collection('dateRequests').doc(dateRequestId).update({
        'initiatorFavorites': favorites,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If both have submitted favorites, move to matching status
      if (partnerFavorites != null && partnerFavorites.isNotEmpty) {
        await _firestore.collection('dateRequests').doc(dateRequestId).update({
          'status': DateRequestStatus.matched.name,
        });

        // Notify partner that matching is ready
        final partnerId = data?['partnerId'] as String?;
        if (partnerId != null) {
          await _notificationStrategy.sendSmartNotification(
            recipientId: partnerId,
            title: '🎯 Ready to Match!',
            body:
                'Both of you have selected favorites. Check out your matched date!',
            type: 'favorites_complete',
            dateRequestId: dateRequestId,
            isUrgent: true,
            sendEmail: true,
          );
        }
      }
    } catch (e) {
      print('Error updating initiator favorites: $e');
      rethrow;
    }
  }

  /// Update partner's favorite selections
  Future<void> updatePartnerFavorites(
    String dateRequestId,
    List<Map<String, dynamic>> favorites,
  ) async {
    try {
      // Get current request to check initiator's favorites
      final doc =
          await _firestore.collection('dateRequests').doc(dateRequestId).get();
      final data = doc.data();
      final initiatorFavorites = data?['initiatorFavorites'] as List?;

      // Update partner favorites
      await _firestore.collection('dateRequests').doc(dateRequestId).update({
        'partnerFavorites': favorites,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // If both have submitted favorites, move to matching status
      if (initiatorFavorites != null && initiatorFavorites.isNotEmpty) {
        await _firestore.collection('dateRequests').doc(dateRequestId).update({
          'status': DateRequestStatus.matched.name,
        });

        // Notify initiator that matching is ready
        final initiatorId = data?['initiatorId'] as String?;
        if (initiatorId != null) {
          await _notificationStrategy.sendSmartNotification(
            recipientId: initiatorId,
            title: '🎯 Ready to Match!',
            body:
                'Both of you have selected favorites. Check out your matched date!',
            type: 'favorites_complete',
            dateRequestId: dateRequestId,
            isUrgent: true,
            sendEmail: true,
          );
        }
      }
    } catch (e) {
      print('Error updating partner favorites: $e');
      rethrow;
    }
  }

  /// Perform AI matching and save matched date
  Future<void> performMatching(String dateRequestId) async {
    try {
      final doc =
          await _firestore.collection('dateRequests').doc(dateRequestId).get();
      final data = doc.data();

      if (data == null) {
        throw Exception('Date request not found');
      }

      final initiatorFavorites = (data['initiatorFavorites'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];
      final partnerFavorites = (data['partnerFavorites'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [];

      if (initiatorFavorites.isEmpty || partnerFavorites.isEmpty) {
        throw Exception('Both partners must select favorites before matching');
      }

      // This will be called from the UI when ready to match
      // The actual matching logic is in DeepSeekService.matchDateSuggestions()
      // UI will call that method and then save the result here
    } catch (e) {
      print('Error performing matching: $e');
      rethrow;
    }
  }

  /// Save matched date result
  Future<void> saveMatchedDate(
    String dateRequestId,
    Map<String, dynamic> matchedDate,
    String matchType,
    String reasoning,
  ) async {
    try {
      await _firestore.collection('dateRequests').doc(dateRequestId).update({
        'selectedDate': matchedDate,
        'matchType': matchType,
        'matchReasoning': reasoning,
        'status': DateRequestStatus.matched.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Notify both partners about the match
      final doc =
          await _firestore.collection('dateRequests').doc(dateRequestId).get();
      final data = doc.data();

      if (data != null) {
        final initiatorId = data['initiatorId'] as String?;
        final partnerId = data['partnerId'] as String?;

        if (initiatorId != null) {
          await _notificationStrategy.sendSmartNotification(
            recipientId: initiatorId,
            title: '💕 Date Matched!',
            body: 'Your perfect date has been matched. Check it out!',
            type: 'date_matched',
            dateRequestId: dateRequestId,
            isUrgent: true,
            sendEmail: true,
          );
        }

        if (partnerId != null) {
          await _notificationStrategy.sendSmartNotification(
            recipientId: partnerId,
            title: '💕 Date Matched!',
            body: 'Your perfect date has been matched. Check it out!',
            type: 'date_matched',
            dateRequestId: dateRequestId,
            isUrgent: true,
            sendEmail: true,
          );
        }
      }
    } catch (e) {
      print('Error saving matched date: $e');
      rethrow;
    }
  }

  /// Propose a time for the date
  Future<void> proposeTime(
    String dateRequestId,
    String userId,
    DateTime proposedTime,
  ) async {
    try {
      final docRef = _firestore.collection('dateRequests').doc(dateRequestId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Date request not found');
      }

      final dateRequest = DateRequestModel.fromFirestore(doc);
      final proposedTimes = List<Map<String, dynamic>>.from(
        dateRequest.proposedTimes ?? [],
      );

      // Check if there's already a matching proposal (same device scenario)
      bool isDuplicate = false;
      for (var proposal in proposedTimes) {
        final existingTime = (proposal['proposedTime'] as Timestamp).toDate();
        final existingBy = proposal['proposedBy'] as String;
        
        // If same time within 1 minute and same user, it's a duplicate
        if (existingBy == userId &&
            existingTime.difference(proposedTime).abs().inMinutes < 1) {
          isDuplicate = true;
          break;
        }
      }

      if (isDuplicate) {
        // Don't add duplicate, just return success
        return;
      }

      // Add new proposal - Use Timestamp.now() instead of FieldValue.serverTimestamp()
      // because FieldValue.serverTimestamp() is not supported inside arrays
      proposedTimes.add({
        'proposedBy': userId,
        'proposedTime': Timestamp.fromDate(proposedTime),
        'accepted': false,
        'createdAt': Timestamp.now(),
      });

      await docRef.update({
        'proposedTimes': proposedTimes,
        'status': DateRequestStatus.timeNegotiating.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to partner
      final partnerId = dateRequest.initiatorId == userId
          ? dateRequest.partnerId
          : dateRequest.initiatorId;

      // Get user info
      final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
      final partnerData = partnerDoc.data();
      final partnerEmail = partnerData?['email'] as String?;
      final partnerName = partnerData?['displayName'] as String? ?? 'there';
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final userName = userData?['displayName'] as String? ?? 'Your partner';

      // Send smart notification (urgent)
      await _notificationStrategy.sendSmartNotification(
        recipientId: partnerId,
        title: '⏰ New Time Proposed',
        body: '$userName proposed a time for your date!',
        type: 'time_proposed',
        dateRequestId: dateRequestId,
        isUrgent: true,
        sendEmail: true,
      );

      // Send email notification
      if (partnerEmail != null && partnerEmail.isNotEmpty) {
        final formattedTime = '${proposedTime.day}/${proposedTime.month}/${proposedTime.year} at ${proposedTime.hour}:${proposedTime.minute.toString().padLeft(2, '0')}';
        await _emailService.sendTimeProposedEmail(
          recipientEmail: partnerEmail,
          recipientName: partnerName,
          partnerName: userName,
          proposedTime: formattedTime,
          dateRequestId: dateRequestId,
        );
      }
    } catch (e) {
      print('Error proposing time: $e');
      rethrow;
    }
  }

  /// Accept a proposed time
  Future<void> acceptProposedTime(
    String dateRequestId,
    DateTime proposedTime,
  ) async {
    try {
      final docRef = _firestore.collection('dateRequests').doc(dateRequestId);
      final doc = await docRef.get();

      if (!doc.exists) {
        throw Exception('Date request not found');
      }

      final dateRequest = DateRequestModel.fromFirestore(doc);
      final proposedTimes = List<Map<String, dynamic>>.from(
        dateRequest.proposedTimes ?? [],
      );

      // Find and mark the proposed time as accepted
      for (var i = 0; i < proposedTimes.length; i++) {
        final proposedDateTime =
            (proposedTimes[i]['proposedTime'] as Timestamp).toDate();
        if (proposedDateTime.isAtSameMomentAs(proposedTime)) {
          proposedTimes[i]['accepted'] = true;
          break;
        }
      }

      await docRef.update({
        'proposedTimes': proposedTimes,
        'confirmedTime': Timestamp.fromDate(proposedTime),
        'status': DateRequestStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to both partners
      final currentUserId = dateRequest.initiatorId;
      final partnerId = dateRequest.partnerId;

      // Get both users' info
      final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
      final partnerData = partnerDoc.data();
      final partnerEmail = partnerData?['email'] as String?;
      final partnerName = partnerData?['displayName'] as String? ?? 'there';
      
      final initiatorDoc = await _firestore.collection('users').doc(currentUserId).get();
      final initiatorData = initiatorDoc.data();
      final initiatorEmail = initiatorData?['email'] as String?;
      final initiatorName = initiatorData?['displayName'] as String? ?? 'there';

      // Format time
      final formattedTime = '${proposedTime.day}/${proposedTime.month}/${proposedTime.year} at ${proposedTime.hour}:${proposedTime.minute.toString().padLeft(2, '0')}';
      final dateDetails = dateRequest.selectedDate?['name'] ?? 'Your planned date';

      // Send smart notifications (urgent - date confirmed)
      await _notificationStrategy.sendSmartNotification(
        recipientId: partnerId,
        title: '✅ Date Confirmed!',
        body: 'Your date with $initiatorName is set for $formattedTime!',
        type: 'time_confirmed',
        dateRequestId: dateRequestId,
        isUrgent: true,
        sendEmail: true,
      );

      await _notificationStrategy.sendSmartNotification(
        recipientId: currentUserId,
        title: '✅ Date Confirmed!',
        body: 'Your date with $partnerName is set for $formattedTime!',
        type: 'time_confirmed',
        dateRequestId: dateRequestId,
        isUrgent: true,
        sendEmail: true,
      );

      // Send emails to both
      if (partnerEmail != null && partnerEmail.isNotEmpty) {
        await _emailService.sendDateConfirmedEmail(
          recipientEmail: partnerEmail,
          recipientName: partnerName,
          partnerName: initiatorName,
          confirmedTime: formattedTime,
          dateDetails: dateDetails,
          dateRequestId: dateRequestId,
        );
      }

      if (initiatorEmail != null && initiatorEmail.isNotEmpty) {
        await _emailService.sendDateConfirmedEmail(
          recipientEmail: initiatorEmail,
          recipientName: initiatorName,
          partnerName: partnerName,
          confirmedTime: formattedTime,
          dateDetails: dateDetails,
          dateRequestId: dateRequestId,
        );
      }

      // Track milestone
      await _emailService.trackBehavior(
        userId: currentUserId,
        event: 'date_confirmed',
        metadata: {'date_request_id': dateRequestId},
      );
      await _emailService.trackBehavior(
        userId: partnerId,
        event: 'date_confirmed',
        metadata: {'date_request_id': dateRequestId},
      );
    } catch (e) {
      print('Error accepting proposed time: $e');
      rethrow;
    }
  }

  /// Counter-propose a time (same as proposing a new time)
  Future<void> counterProposeTime(
    String dateRequestId,
    String userId,
    DateTime proposedTime,
  ) async {
    // Counter-proposing is the same as proposing a new time
    return proposeTime(dateRequestId, userId, proposedTime);
  }

  /// Confirm the date
  Future<void> confirmDate(
    String dateRequestId,
    DateTime confirmedTime,
  ) async {
    try {
      await _firestore.collection('dateRequests').doc(dateRequestId).update({
        'confirmedTime': Timestamp.fromDate(confirmedTime),
        'status': DateRequestStatus.confirmed.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error confirming date: $e');
      rethrow;
    }
  }

  /// Cancel date request
  Future<void> cancelDateRequest(String dateRequestId) async {
    try {
      await _firestore.collection('dateRequests').doc(dateRequestId).delete();
    } catch (e) {
      print('Error cancelling date request: $e');
      rethrow;
    }
  }


}
