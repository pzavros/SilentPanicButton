import 'package:intl/intl.dart';

class AlertBuilder {
  /// Build alert message from template
  /// userName: User's custom name or null for default
  /// latitude, longitude: GPS coordinates
  /// batteryPercent: Battery percentage or null
  /// timestamp: DateTime of the alert
  static String buildMessage({
    String? userName,
    required double latitude,
    required double longitude,
    int? batteryPercent,
    required DateTime timestamp,
  }) {
    final name =
        userName?.trim().isNotEmpty == true ? userName : 'Someone you trust';

    final mapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

    final timeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final localTime = timeFormat.format(timestamp);

    final batteryText = batteryPercent != null
        ? 'Battery: $batteryPercent%'
        : 'Battery: Unknown';

    return '''🚨 EMERGENCY ALERT

$name needs immediate assistance and has activated their emergency alert.

━━━━━━━━━━━━━━━━━━━━━━━━
📍 LIVE LOCATION
$mapsUrl

⏰ Alert Time: $localTime
🔋 Device Status: $batteryText

━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ ACTION REQUIRED
Please check on their safety immediately or contact emergency services if needed.

This alert was sent automatically via Silent Panic Button.''';
  }

  /// Build all-clear message
  static String buildAllClearMessage({
    String? userName,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
  }) {
    final name =
        userName?.trim().isNotEmpty == true ? userName : 'Someone you trust';

    final mapsUrl = 'https://maps.google.com/?q=$latitude,$longitude';

    final timeFormat = DateFormat('MMM dd, yyyy • hh:mm a');
    final localTime = timeFormat.format(timestamp);

    return '''✅ ALL CLEAR - SITUATION RESOLVED

$name has confirmed that they are now safe and the emergency situation has been resolved.

━━━━━━━━━━━━━━━━━━━━━━━━
📍 CURRENT LOCATION
$mapsUrl

⏰ All-Clear Sent: $localTime

━━━━━━━━━━━━━━━━━━━━━━━━

Thank you for your concern and readiness to help.

This update was sent via Silent Panic Button.''';
  }
}
