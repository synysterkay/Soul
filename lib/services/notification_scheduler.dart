import 'dart:async';
import 'notification_strategy_service.dart';

/// Background scheduler for automated notifications
/// Runs daily checks for engagement notifications (morning motivation, evening ideas, re-engagement)
class NotificationScheduler {
  static final NotificationScheduler _instance = NotificationScheduler._internal();
  factory NotificationScheduler() => _instance;
  NotificationScheduler._internal();

  final NotificationStrategyService _strategy = NotificationStrategyService();
  Timer? _dailyTimer;
  bool _isRunning = false;

  /// Start the notification scheduler
  void start() {
    if (_isRunning) {
      print('⚠️ Notification scheduler already running');
      return;
    }

    _isRunning = true;
    print('✅ Notification scheduler started');

    // Run immediately on start
    _runDailyCheck();

    // Then run every hour (check if it's time to send)
    _dailyTimer = Timer.periodic(Duration(hours: 1), (timer) {
      _runDailyCheck();
    });
  }

  /// Stop the notification scheduler
  void stop() {
    _dailyTimer?.cancel();
    _dailyTimer = null;
    _isRunning = false;
    print('🛑 Notification scheduler stopped');
  }

  /// Run daily notification checks
  Future<void> _runDailyCheck() async {
    try {
      final now = DateTime.now();
      print('🔄 Running notification check at ${now.hour}:${now.minute}');

      // Process all daily notifications
      await _strategy.processDailyNotifications();

      print('✅ Notification check completed');
    } catch (e) {
      print('❌ Error in notification check: $e');
    }
  }

  /// Manual trigger for testing
  Future<void> runNow() async {
    print('🧪 Manual notification check triggered');
    await _runDailyCheck();
  }
}
