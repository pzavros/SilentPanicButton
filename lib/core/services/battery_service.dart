import 'package:battery_plus/battery_plus.dart';

class BatteryService {
  final Battery _battery = Battery();

  /// Get current battery percentage (0-100)
  /// Returns null if unable to fetch
  Future<int?> getBatteryPercent() async {
    try {
      final batteryLevel = await _battery.batteryLevel;
      return batteryLevel;
    } catch (e) {
      // If battery info unavailable, return null
      return null;
    }
  }
}
