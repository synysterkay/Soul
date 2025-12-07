import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Your OneSignal App ID and REST API Key from https://app.onesignal.com
  static const String _appId = '369027f2-a9c9-4c3c-9234-062e785220e1';
  static const String _restApiKey = 'os_v2_app_g2icp4vjzfgdzeruayxhqura4ebyq3cyeuyewofdnxfahb7i5x4tbixt4hjlcornqqgxdm2lzh5ouogqged66tjidgurtll2dhjyopi';
  
  // Store navigation key for deep linking
  GlobalKey<NavigatorState>? navigatorKey;

  /// Initialize OneSignal
  Future<void> initialize() async {
    try {
      // Initialize OneSignal
      OneSignal.initialize(_appId);

      // Request notification permission (iOS)
      await OneSignal.Notifications.requestPermission(true);

      // Handle notification received while app is in foreground
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        print('📬 Notification received in foreground: ${event.notification.title}');
        // Display the notification
        event.notification.display();
      });

      // Handle notification opened/clicked
      OneSignal.Notifications.addClickListener((event) {
        print('🔔 Notification clicked: ${event.notification.additionalData}');
        final data = event.notification.additionalData;
        if (data != null) {
          _handleNotificationClick(data);
        }
      });

      // Save OneSignal player ID to Firestore when user is logged in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _savePlayerIdToFirestore(currentUser.uid);
      }

      // Listen to auth state changes to update OneSignal ID
      _auth.authStateChanges().listen((user) {
        if (user != null) {
          _savePlayerIdToFirestore(user.uid);
        }
      });

      print('✅ OneSignal initialized successfully');
    } catch (e) {
      print('❌ Error initializing OneSignal: $e');
    }
  }

  /// Save OneSignal player ID to Firestore
  Future<void> _savePlayerIdToFirestore(String userId) async {
    try {
      // Get the OneSignal player ID
      final playerId = OneSignal.User.pushSubscription.id;
      
      if (playerId != null && playerId.isNotEmpty) {
        // Save to Firestore
        await _firestore.collection('users').doc(userId).update({
          'oneSignalId': playerId,
          'oneSignalUpdatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ OneSignal player ID saved: $playerId');
      }
    } catch (e) {
      print('❌ Error saving OneSignal player ID: $e');
    }
  }

  /// Handle notification click based on data
  void _handleNotificationClick(Map<String, dynamic> data) {
    print('📱 Handling notification click with data: $data');
    
    if (navigatorKey?.currentState == null) {
      print('⚠️ Navigator not available yet');
      return;
    }

    final type = data['type']?.toString();
    final dateRequestId = data['dateRequestId']?.toString();

    if (type == null || dateRequestId == null) {
      print('⚠️ Missing notification data: type=$type, dateRequestId=$dateRequestId');
      return;
    }

    // Navigate based on notification type
    switch (type) {
      case 'time_proposed':
      case 'time_confirmed':
        // Navigate to time negotiation screen
        print('🔄 Navigating to time negotiation: $dateRequestId');
        navigatorKey!.currentState!.pushNamed(
          '/time-negotiation',
          arguments: {'dateRequestId': dateRequestId},
        );
        break;
      
      case 'questionnaire_invite':
        // Navigate to questionnaire screen
        print('🔄 Navigating to questionnaire: $dateRequestId');
        navigatorKey!.currentState!.pushNamed(
          '/questionnaire',
          arguments: {'dateRequestId': dateRequestId},
        );
        break;
      
      case 'date_matched':
      case 'date_request':
        // Navigate to dates list screen
        print('🔄 Navigating to dates screen');
        navigatorKey!.currentState!.pushNamed('/dates');
        break;
      
      default:
        print('⚠️ Unknown notification type: $type');
    }
  }

  /// Send notification using OneSignal REST API
  Future<void> sendNotification({
    required String recipientId,
    required String title,
    required String body,
    required String notificationType,
    required String dateRequestId,
  }) async {
    try {
      // Get recipient's OneSignal player ID from Firestore
      final userDoc = await _firestore.collection('users').doc(recipientId).get();
      
      if (!userDoc.exists) {
        print('⚠️ User not found: $recipientId');
        return;
      }

      final oneSignalId = userDoc.data()?['oneSignalId'] as String?;
      
      if (oneSignalId == null || oneSignalId.isEmpty) {
        print('⚠️ No OneSignal ID found for user: $recipientId');
        return;
      }

      // Send notification via OneSignal REST API
      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode({
          'app_id': _appId,
          'include_player_ids': [oneSignalId],
          'headings': {'en': title},
          'contents': {'en': body},
          'data': {
            'type': notificationType,
            'dateRequestId': dateRequestId,
          },
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully to $recipientId');
        print('   Title: $title');
        print('   Body: $body');
        print('   Type: $notificationType');
      } else {
        print('❌ Failed to send notification: ${response.statusCode}');
        print('   Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Error sending notification: $e');
    }
  }

  /// Set external user ID (link OneSignal ID with your user ID)
  Future<void> setExternalUserId(String userId) async {
    try {
      await OneSignal.login(userId);
      print('✅ OneSignal external user ID set: $userId');
    } catch (e) {
      print('❌ Error setting external user ID: $e');
    }
  }

  /// Remove external user ID on logout
  Future<void> removeExternalUserId() async {
    try {
      await OneSignal.logout();
      print('✅ OneSignal external user ID removed');
    } catch (e) {
      print('❌ Error removing external user ID: $e');
    }
  }
}
