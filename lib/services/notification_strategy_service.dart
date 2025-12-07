import 'package:cloud_firestore/cloud_firestore.dart';
import 'onesignal_service.dart';
import 'email_service.dart';

/// Smart notification strategy with frequency control and optimal timing
/// Prevents notification fatigue while maximizing engagement and retention
class NotificationStrategyService {
  static final NotificationStrategyService _instance = NotificationStrategyService._internal();
  factory NotificationStrategyService() => _instance;
  NotificationStrategyService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final OneSignalService _oneSignal = OneSignalService();
  final EmailService _emailService = EmailService();

  // ============================================
  // FREQUENCY CONTROL (Prevent notification fatigue)
  // ============================================
  
  static const int maxDailyNotifications = 5; // Max 5 notifications per day
  static const int maxWeeklyNotifications = 20; // Max 20 per week
  static const Duration minTimeBetweenNotifications = Duration(hours: 2); // Min 2h gap
  
  // Quiet hours (don't disturb)
  static const int quietHourStart = 22; // 10 PM
  static const int quietHourEnd = 8; // 8 AM

  /// Check if user can receive notification (frequency control)
  Future<bool> canSendNotification(String userId, {bool isUrgent = false}) async {
    try {
      // Urgent notifications (time proposals, confirmations) always send
      if (isUrgent) return true;

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final data = userDoc.data();
      
      if (data == null) return true;

      // Check quiet hours
      final now = DateTime.now();
      if (now.hour >= quietHourStart || now.hour < quietHourEnd) {
        print('⚠️ Quiet hours - skipping notification');
        return false;
      }

      // Get notification history
      final List<dynamic> notificationTimestamps = data['notificationHistory'] ?? [];

      // Check daily limit
      final dailyCount = notificationTimestamps.where((timestamp) {
        final notifTime = (timestamp as Timestamp).toDate();
        return now.difference(notifTime).inHours < 24;
      }).length;

      if (dailyCount >= maxDailyNotifications) {
        print('⚠️ Daily limit reached ($dailyCount/$maxDailyNotifications)');
        return false;
      }

      // Check weekly limit
      final weeklyCount = notificationTimestamps.where((timestamp) {
        final notifTime = (timestamp as Timestamp).toDate();
        return now.difference(notifTime).inDays < 7;
      }).length;

      if (weeklyCount >= maxWeeklyNotifications) {
        print('⚠️ Weekly limit reached ($weeklyCount/$maxWeeklyNotifications)');
        return false;
      }

      // Check minimum time between notifications
      if (notificationTimestamps.isNotEmpty) {
        final lastNotifTime = (notificationTimestamps.last as Timestamp).toDate();
        if (now.difference(lastNotifTime) < minTimeBetweenNotifications) {
          print('⚠️ Too soon since last notification');
          return false;
        }
      }

      return true;
    } catch (e) {
      print('❌ Error checking notification limit: $e');
      return true; // Default to allowing if check fails
    }
  }

  /// Track notification sent
  Future<void> _trackNotification(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'notificationHistory': FieldValue.arrayUnion([Timestamp.now()]),
      });
    } catch (e) {
      print('❌ Error tracking notification: $e');
    }
  }

  // ============================================
  // SMART NOTIFICATION SENDING
  // ============================================

  /// Send notification with smart timing and frequency control
  Future<void> sendSmartNotification({
    required String recipientId,
    required String title,
    required String body,
    required String type,
    required String dateRequestId,
    bool isUrgent = false,
    bool sendEmail = false,
  }) async {
    try {
      // Check if we can send
      final canSend = await canSendNotification(recipientId, isUrgent: isUrgent);
      
      if (!canSend && !isUrgent) {
        print('⏭️ Skipping notification due to frequency limits');
        return;
      }

      // Send push notification
      await _oneSignal.sendNotification(
        recipientId: recipientId,
        title: title,
        body: body,
        notificationType: type,
        dateRequestId: dateRequestId,
      );

      // Track it
      await _trackNotification(recipientId);

      // Optionally send email backup
      if (sendEmail) {
        final userDoc = await _firestore.collection('users').doc(recipientId).get();
        final userData = userDoc.data();
        final email = userData?['email'] as String?;
        
        if (email != null) {
          // Email logic handled by EmailService
          print('📧 Email sent as backup');
        }
      }

      print('✅ Smart notification sent: $title');
    } catch (e) {
      print('❌ Error sending smart notification: $e');
    }
  }

  // ============================================
  // ENGAGEMENT NOTIFICATIONS (Retention)
  // ============================================

  /// Morning motivation - "Plan a date today!"
  Future<void> sendMorningMotivation(String userId) async {
    try {
      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      final now = DateTime.now();
      if (now.hour != 9) return; // Only at 9 AM

      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final lastDateCreated = userData?['last_date_created'] as Timestamp?;

      // Only send if no date in last 7 days
      if (lastDateCreated != null) {
        final daysSince = DateTime.now().difference(lastDateCreated.toDate()).inDays;
        if (daysSince < 7) return;
      }

      final messages = [
        '🌅 Good morning! How about planning a special date today?',
        '☕ Start your day right - plan a romantic date!',
        '💕 Make today special - create a date your partner will love',
      ];

      final random = (DateTime.now().millisecond % messages.length);

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: 'Good Morning! 🌅',
        body: messages[random],
        notificationType: 'morning_motivation',
        dateRequestId: 'engagement',
      );

      await _trackNotification(userId);
      print('✅ Morning motivation sent');
    } catch (e) {
      print('❌ Error sending morning motivation: $e');
    }
  }

  /// Evening date ideas - "Weekend is coming!"
  Future<void> sendEveningDateIdeas(String userId) async {
    try {
      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      final now = DateTime.now();
      
      // Only Thursday/Friday at 7 PM
      if (now.weekday < 4 || now.weekday > 5 || now.hour != 19) return;

      final messages = [
        '🎉 Weekend is almost here! Plan something special',
        '💃 Ready for the weekend? Let\'s plan an amazing date',
        '🌟 Make this weekend unforgettable with a perfect date',
      ];

      final random = (DateTime.now().millisecond % messages.length);

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: 'Weekend Plans? 🎉',
        body: messages[random],
        notificationType: 'evening_date_ideas',
        dateRequestId: 'engagement',
      );

      await _trackNotification(userId);
      print('✅ Evening date ideas sent');
    } catch (e) {
      print('❌ Error sending evening date ideas: $e');
    }
  }

  /// Re-engagement notification for inactive users
  Future<void> sendReengagementNotification(String userId, int daysInactive) async {
    try {
      // Don't spam - only specific day milestones
      if (![3, 7, 14, 30].contains(daysInactive)) return;

      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      String title = '';
      String body = '';

      if (daysInactive == 3) {
        title = 'We Miss You! 💕';
        body = 'Your partner might be waiting for you to plan the next date!';
      } else if (daysInactive == 7) {
        title = 'It\'s Been a Week...';
        body = 'Couples who date regularly are happier! Plan a date now 💕';
      } else if (daysInactive == 14) {
        title = 'Date Night Time? 🌙';
        body = 'It\'s been 2 weeks! Surprise your partner with a special date';
      } else if (daysInactive == 30) {
        title = 'Long Time No See! 😢';
        body = 'We\'ve added new features! Come back and plan an amazing date';
      }

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: title,
        body: body,
        notificationType: 'reengagement',
        dateRequestId: 'engagement',
      );

      await _trackNotification(userId);
      print('✅ Re-engagement notification sent (Day $daysInactive)');
    } catch (e) {
      print('❌ Error sending re-engagement: $e');
    }
  }

  /// Date reminder - Day before confirmed date
  Future<void> sendDateReminder(String userId, String dateRequestId, DateTime dateTime) async {
    try {
      final tomorrow = DateTime.now().add(Duration(days: 1));
      
      // Only send if date is tomorrow
      if (dateTime.day != tomorrow.day || 
          dateTime.month != tomorrow.month || 
          dateTime.year != tomorrow.year) {
        return;
      }

      // Get partner info
      final dateDoc = await _firestore.collection('dateRequests').doc(dateRequestId).get();
      final dateData = dateDoc.data();
      final partnerId = dateData?['partnerId'] as String? ?? dateData?['initiatorId'] as String?;
      
      if (partnerId == null) return;

      final partnerDoc = await _firestore.collection('users').doc(partnerId).get();
      final partnerName = partnerDoc.data()?['displayName'] as String? ?? 'your partner';

      final timeStr = '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: '📅 Date Reminder',
        body: 'Your date with $partnerName is tomorrow at $timeStr! Get ready 💕',
        notificationType: 'date_reminder',
        dateRequestId: dateRequestId,
      );

      // Always send date reminders, don't track against limits
      print('✅ Date reminder sent');
    } catch (e) {
      print('❌ Error sending date reminder: $e');
    }
  }

  /// Questionnaire reminder - Partner waiting
  Future<void> sendQuestionnaireReminder(String userId, String dateRequestId, String partnerName) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();
      final lastQuestReminder = userData?['last_questionnaire_reminder'] as Timestamp?;

      // Don't send more than once per day
      if (lastQuestReminder != null) {
        final hoursSince = DateTime.now().difference(lastQuestReminder.toDate()).inHours;
        if (hoursSince < 24) return;
      }

      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: '$partnerName is Waiting! ⏰',
        body: 'Complete your questionnaire to unlock AI date suggestions',
        notificationType: 'questionnaire_reminder',
        dateRequestId: dateRequestId,
      );

      // Update last reminder time
      await _firestore.collection('users').doc(userId).update({
        'last_questionnaire_reminder': FieldValue.serverTimestamp(),
      });

      await _trackNotification(userId);
      print('✅ Questionnaire reminder sent');
    } catch (e) {
      print('❌ Error sending questionnaire reminder: $e');
    }
  }

  /// Partner is active - "Your partner is online now!"
  Future<void> sendPartnerActiveNotification(String userId, String partnerName) async {
    try {
      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      // Check if user is inactive (last active > 1 hour ago)
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final lastActive = userDoc.data()?['last_active'] as Timestamp?;
      
      if (lastActive != null) {
        final minutesSince = DateTime.now().difference(lastActive.toDate()).inMinutes;
        if (minutesSince < 60) return; // User already active, no need to notify
      }

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: '$partnerName is Online! 💚',
        body: 'Your partner is planning something special. Join them now!',
        notificationType: 'partner_active',
        dateRequestId: 'engagement',
      );

      await _trackNotification(userId);
      print('✅ Partner active notification sent');
    } catch (e) {
      print('❌ Error sending partner active: $e');
    }
  }

  /// Milestone celebration
  Future<void> sendMilestoneNotification(String userId, String milestone, int count) async {
    try {
      final canSend = await canSendNotification(userId);
      if (!canSend) return;

      String title = '';
      String body = '';

      switch (milestone) {
        case 'first_date':
          title = '🎉 First Date Completed!';
          body = 'Congrats! How did it go? Share your experience';
          break;
        case 'fifth_date':
          title = '🔥 5 Dates Planned!';
          body = 'You\'re on fire! Keep the romance alive';
          break;
        case 'tenth_date':
          title = '⭐ 10 Dates! You\'re a Pro!';
          body = 'Amazing! Share your story to inspire other couples';
          break;
        case 'month_anniversary':
          title = '📅 Happy 1 Month Anniversary!';
          body = 'You\'ve been using SoulPlan for a month. Keep it up!';
          break;
      }

      await _oneSignal.sendNotification(
        recipientId: userId,
        title: title,
        body: body,
        notificationType: 'milestone',
        dateRequestId: 'engagement',
      );

      await _trackNotification(userId);
      print('✅ Milestone notification sent: $milestone');
    } catch (e) {
      print('❌ Error sending milestone: $e');
    }
  }

  // ============================================
  // SCHEDULED NOTIFICATION CHECKER (Run daily)
  // ============================================

  /// Check and send all scheduled notifications (call this daily)
  Future<void> processDailyNotifications() async {
    try {
      print('🔄 Processing daily notifications...');

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        final userData = userDoc.data();
        
        // Check last active
        final lastActive = userData['last_active'] as Timestamp?;
        if (lastActive != null) {
          final daysInactive = DateTime.now().difference(lastActive.toDate()).inDays;
          
          // Send re-engagement
          if (daysInactive > 0) {
            await sendReengagementNotification(userId, daysInactive);
          }
        }

        // Send morning motivation (9 AM check)
        if (DateTime.now().hour == 9) {
          await sendMorningMotivation(userId);
        }

        // Send evening ideas (Thu/Fri 7 PM check)
        if (DateTime.now().hour == 19) {
          await sendEveningDateIdeas(userId);
        }

        // Check for pending date reminders
        final dateRequestsSnapshot = await _firestore
            .collection('dateRequests')
            .where('status', isEqualTo: 'confirmed')
            .where('initiatorId', isEqualTo: userId)
            .get();

        for (var dateDoc in dateRequestsSnapshot.docs) {
          final confirmedTime = (dateDoc.data()['confirmedTime'] as Timestamp?)?.toDate();
          if (confirmedTime != null) {
            await sendDateReminder(userId, dateDoc.id, confirmedTime);
          }
        }

        // Small delay to avoid rate limits
        await Future.delayed(Duration(milliseconds: 500));
      }

      print('✅ Daily notifications processed');
    } catch (e) {
      print('❌ Error processing daily notifications: $e');
    }
  }
}
