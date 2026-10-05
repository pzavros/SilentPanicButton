import 'package:flutter/foundation.dart';

/// Simplified NotificationService without Firebase
/// This is a stub implementation that will work without push notification dependencies
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  /// Initialize notification service (stub)
  Future<void> initialize() async {
    try {
      debugPrint('✅ NotificationService initialized (simplified mode)');
      debugPrint('💡 Push notifications disabled - Firebase removed');
    } catch (e) {
      debugPrint('❌ NotificationService initialization error: $e');
    }
  }

  /// Send panic alert notification (stub)
  Future<void> sendPanicAlert({
    required String userName,
    required double latitude,
    required double longitude,
    String? batteryLevel,
  }) async {
    debugPrint('📱 Panic alert would be sent:');
    debugPrint('   User: $userName');
    debugPrint('   Location: $latitude, $longitude');
    if (batteryLevel != null) {
      debugPrint('   Battery: $batteryLevel');
    }
    debugPrint('💡 To enable: Add Firebase dependencies back to pubspec.yaml');
  }

  /// Send all-clear notification (stub)
  Future<void> sendAllClearNotification({
    required String userName,
  }) async {
    debugPrint('📱 All-clear notification would be sent for: $userName');
    debugPrint('💡 To enable: Add Firebase dependencies back to pubspec.yaml');
  }

  /// Show local notification (stub)
  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('🔔 Local notification would show:');
    debugPrint('   Title: $title');
    debugPrint('   Body: $body');
  }
}
