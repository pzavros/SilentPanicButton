import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/models/alert_event.dart';
import '../../core/services/location_service.dart';
import '../../core/services/battery_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/share_service.dart';
import '../../core/services/notification_service.dart';
// import '../../core/services/widget_service.dart'; // Requires paid Apple Developer account
import '../../core/theme/ios_dialog.dart';
import '../alert/alert_builder.dart';
import '../contacts/contacts_page.dart';
import '../history/history_page.dart';
import '../privacy/privacy_page.dart';
import 'widgets/hold_to_alert_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AlertEvent? _activeAlert;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadActiveAlert();
  }

  void _loadActiveAlert() {
    final storage = Provider.of<StorageService>(context, listen: false);
    setState(() {
      _activeAlert = storage.getActiveAlert();
    });
  }

  Future<void> _handlePanicActivation() async {
    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final batteryService = Provider.of<BatteryService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Get location
      final position = await locationService.getCurrentPosition();

      // Get battery
      final battery = await batteryService.getBatteryPercent();

      // Build message
      final userName = storageService.getUserName();
      final now = DateTime.now();
      final message = AlertBuilder.buildMessage(
        userName: userName,
        latitude: position.latitude,
        longitude: position.longitude,
        batteryPercent: battery,
        timestamp: now,
      );

      // Create alert event
      final event = AlertEvent(
        id: const Uuid().v4(),
        createdAt: now,
        latitude: position.latitude,
        longitude: position.longitude,
        batteryPercent: battery,
        shareMessage: message,
      );

      // Save to history
      await storageService.addAlert(event);

      // Update active alert
      setState(() {
        _activeAlert = event;
      });

      // Update widget to show panic active (requires paid Apple Developer account)
      // Uncomment when you have App Groups capability:
      // try {
      //   final widgetService = WidgetService();
      //   final activeContacts = storageService.getActiveContacts();
      //   await widgetService.updatePanicActive();
      // } catch (e) {
      //   debugPrint('⚠️ Widget update error: $e');
      // }

      // Close loading
      if (mounted) {
        Navigator.of(context).pop();

        // Get active contacts
        final activeContacts = storageService.getActiveContacts();
        final contactsWithPhone = activeContacts
            .where((c) => c.phone != null && c.phone!.isNotEmpty)
            .toList();
        final contactsWithFCM = activeContacts
            .where((c) => c.fcmToken != null && c.fcmToken!.isNotEmpty)
            .toList();

        // Automatically send push notifications to contacts with FCM tokens
        if (contactsWithFCM.isNotEmpty) {
          try {
            final notificationService = NotificationService();
            final userName = storageService.getUserName() ?? 'Someone';
            final fcmTokens = contactsWithFCM
                .map((c) => c.fcmToken!)
                .toList();
            
            await notificationService.sendPanicAlert(
              fcmTokens: fcmTokens,
              senderName: userName,
              latitude: position.latitude,
              longitude: position.longitude,
              message: message,
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🔔 Alert sent to ${contactsWithFCM.length} contact${contactsWithFCM.length > 1 ? 's' : ''}'),
                  backgroundColor: const Color(0xFF10B981),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('⚠️ Push notification error: $e');
          }
        }

        // Show dialog for additional sharing options
        final theme = Theme.of(context);
        final action = await IOSDialog.show<String>(
          context: context,
          icon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 36,
              color: theme.colorScheme.error,
            ),
          ),
          title: 'Panic Alert Created',
          content: contactsWithFCM.isNotEmpty
              ? '✅ Push notifications sent!\n\nWant to also send via SMS or share?'
              : 'Send alert to your emergency contacts',
          actions: [
            if (contactsWithPhone.isNotEmpty)
              IOSDialogAction(
                label: 'Send SMS (${contactsWithPhone.length} contact${contactsWithPhone.length > 1 ? 's' : ''})',
                returnValue: 'sms',
                isPrimary: contactsWithFCM.isEmpty,
              ),
            IOSDialogAction(
              label: 'Share Other Way',
              returnValue: 'share',
              isPrimary: contactsWithPhone.isEmpty && contactsWithFCM.isEmpty,
            ),
            IOSDialogAction(
              label: contactsWithFCM.isNotEmpty ? 'Done' : 'Not Now',
              returnValue: null,
            ),
          ],
        );

        if (action == 'sms' && mounted) {
          // Send SMS to contacts with phone numbers
          try {
            final phoneNumbers = contactsWithPhone
                .map((c) => c.phone!)
                .toList();
            
            final shareService = Provider.of<ShareService>(context, listen: false);
            await shareService.sendSMS(
              message: message,
              recipients: phoneNumbers,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SMS Error: ${e.toString()}'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        } else if (action == 'share' && mounted) {
          // Use share sheet
          final shareService = Provider.of<ShareService>(context, listen: false);
          await shareService.shareAlert(message);
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) {
        Navigator.of(context).pop();

        // Show error
        await IOSDialog.show(
          context: context,
          icon: Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          ),
          title: 'Error',
          content: e.toString(),
          actions: [
            IOSDialogAction(
              label: 'OK',
              isPrimary: true,
            ),
          ],
        );
      }
    }
  }

  Future<void> _handleAllClearActivation() async {
    if (_activeAlert == null) return;

    final locationService =
        Provider.of<LocationService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);

    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );

      // Get current location
      final position = await locationService.getCurrentPosition();

      // Build all-clear message
      final userName = storageService.getUserName();
      final now = DateTime.now();
      final message = AlertBuilder.buildAllClearMessage(
        userName: userName,
        latitude: position.latitude,
        longitude: position.longitude,
        timestamp: now,
      );

      // Resolve the active alert
      await storageService.resolveAlert(_activeAlert!.id);

      // Update widget to show ready state (requires paid Apple Developer account)
      // Uncomment when you have App Groups capability:
      // try {
      //   final widgetService = WidgetService();
      //   final activeContacts = storageService.getActiveContacts();
      //   await widgetService.updateReady(activeContacts.length);
      // } catch (e) {
      //   debugPrint('⚠️ Widget update error: $e');
      // }

      // Close loading
      if (mounted) {
        Navigator.of(context).pop();

        // Get active contacts
        final activeContacts = storageService.getActiveContacts();
        final contactsWithPhone = activeContacts
            .where((c) => c.phone != null && c.phone!.isNotEmpty)
            .toList();
        final contactsWithFCM = activeContacts
            .where((c) => c.fcmToken != null && c.fcmToken!.isNotEmpty)
            .toList();

        // Automatically send push notifications to contacts with FCM tokens
        if (contactsWithFCM.isNotEmpty) {
          try {
            final notificationService = NotificationService();
            final userName = storageService.getUserName() ?? 'Someone';
            final fcmTokens = contactsWithFCM
                .map((c) => c.fcmToken!)
                .toList();
            
            await notificationService.sendAllClearNotification(
              fcmTokens: fcmTokens,
              senderName: userName,
              latitude: position.latitude,
              longitude: position.longitude,
            );
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ All-clear sent to ${contactsWithFCM.length} contact${contactsWithFCM.length > 1 ? 's' : ''}'),
                  backgroundColor: const Color(0xFF10B981),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            debugPrint('⚠️ Push notification error: $e');
          }
        }

        // Show dialog for additional sharing options
        final theme = Theme.of(context);
        final action = await IOSDialog.show<String>(
          context: context,
          icon: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 36,
              color: Color(0xFF10B981),
            ),
          ),
          title: 'All Clear',
          content: contactsWithFCM.isNotEmpty
              ? '✅ All-clear notifications sent!\n\nWant to also send via SMS or share?'
              : 'Send all-clear message to your emergency contacts',
          actions: [
            if (contactsWithPhone.isNotEmpty)
              IOSDialogAction(
                label: 'Send SMS (${contactsWithPhone.length} contact${contactsWithPhone.length > 1 ? 's' : ''})',
                returnValue: 'sms',
                isPrimary: contactsWithFCM.isEmpty,
              ),
            IOSDialogAction(
              label: 'Share Other Way',
              returnValue: 'share',
              isPrimary: contactsWithPhone.isEmpty && contactsWithFCM.isEmpty,
            ),
            IOSDialogAction(
              label: contactsWithFCM.isNotEmpty ? 'Done' : 'Not Now',
              returnValue: null,
            ),
          ],
        );

        if (action == 'sms' && mounted) {
          // Send SMS to contacts with phone numbers
          try {
            final phoneNumbers = contactsWithPhone
                .map((c) => c.phone!)
                .toList();
            
            final shareService = Provider.of<ShareService>(context, listen: false);
            await shareService.sendSMS(
              message: message,
              recipients: phoneNumbers,
            );
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('SMS Error: ${e.toString()}'),
                  backgroundColor: theme.colorScheme.error,
                ),
              );
            }
          }
        } else if (action == 'share' && mounted) {
          // Use share sheet
          final shareService = Provider.of<ShareService>(context, listen: false);
          await shareService.shareAlert(message);
        }

        // Update active alert state
        setState(() {
          _activeAlert = null;
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Alert marked as resolved'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        }
      }
    } catch (e) {
      // Close loading
      if (mounted) {
        Navigator.of(context).pop();

        // Show error
        await IOSDialog.show(
          context: context,
          icon: Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error.withOpacity(0.8),
          ),
          title: 'Error',
          content: e.toString(),
          actions: [
            IOSDialogAction(
              label: 'OK',
              isPrimary: true,
            ),
          ],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0A0A0A),
                  ]
                : [
                    const Color(0xFFF5F5F7),
                    const Color(0xFFE5E5EA),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header with Status
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Silent Panic',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -1.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Emergency Alert System',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13,
                                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                        // Status indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _activeAlert != null
                                ? const Color(0xFFEF4444).withOpacity(0.15)
                                : const Color(0xFF10B981).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _activeAlert != null
                                  ? const Color(0xFFEF4444).withOpacity(0.3)
                                  : const Color(0xFF10B981).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _activeAlert != null
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _activeAlert != null ? 'Active' : 'Ready',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _activeAlert != null
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main button area with instruction
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HoldToAlertButton(
                        onAlertTriggered: _handlePanicActivation,
                        onAllClearTriggered: _handleAllClearActivation,
                        activeAlert: _activeAlert,
                      ),
                      const SizedBox(height: 32),
                      // Instruction text
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withOpacity(0.05)
                              : Colors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app,
                              size: 20,
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                _activeAlert != null
                                    ? 'Press & hold for 2 seconds to send all-clear'
                                    : 'Press & hold for 2 seconds to alert',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                                  letterSpacing: -0.1,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Modern Navigation Cards
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _NavButton(
                        icon: Icons.people_outline,
                        label: 'Contacts',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const ContactsPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NavButton(
                        icon: Icons.history,
                        label: 'History',
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const HistoryPage(),
                            ),
                          );
                          _loadActiveAlert();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _NavButton(
                        icon: Icons.shield_outlined,
                        label: 'Privacy',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const PrivacyPage(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.1)
                  : Colors.black.withOpacity(0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
