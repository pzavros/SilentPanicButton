import 'package:home_widget/home_widget.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.silentpanic.silentPanicButton';
  static const String _statusKey = 'panic_status';
  static const String _contactCountKey = 'contact_count';
  static const String _lastAlertKey = 'last_alert';
  
  /// Initialize widget service
  Future<void> initialize() async {
    try {
      // Set app group for iOS
      await HomeWidget.setAppGroupId(_appGroupId);
      
      // Register callback for widget interactions
      HomeWidget.registerInteractivityCallback(_handleWidgetTap);
      
      print('✅ Widget service initialized');
    } catch (e) {
      print('⚠️ Widget initialization error: $e');
    }
  }
  
  /// Update widget with current status
  Future<void> updateWidget({
    required String status,
    required int contactCount,
    String? lastAlert,
  }) async {
    try {
      // Save data to widget
      await HomeWidget.saveWidgetData<String>(_statusKey, status);
      await HomeWidget.saveWidgetData<int>(_contactCountKey, contactCount);
      if (lastAlert != null) {
        await HomeWidget.saveWidgetData<String>(_lastAlertKey, lastAlert);
      }
      
      // Update widget UI
      await HomeWidget.updateWidget(
        iOSName: 'PanicWidget',
        qualifiedAndroidName: 'com.silentpanic.silentPanicButton.PanicWidget',
      );
    } catch (e) {
      print('Error updating widget: $e');
    }
  }
  
  /// Handle widget tap events
  static void _handleWidgetTap(Uri? uri) {
    if (uri != null) {
      // Handle different widget actions
      final action = uri.host;
      print('Widget action: $action');
      
      // You can emit events here to notify the app
      // For example, trigger panic alert from widget
    }
  }
  
  /// Update widget to show panic active
  Future<void> updatePanicActive() async {
    await updateWidget(
      status: 'active',
      contactCount: 0, // Will be set by caller
      lastAlert: DateTime.now().toString(),
    );
  }
  
  /// Update widget to show ready state
  Future<void> updateReady(int contactCount) async {
    await updateWidget(
      status: 'ready',
      contactCount: contactCount,
    );
  }
}
