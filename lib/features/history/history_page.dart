import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/share_service.dart';
import '../../core/theme/ios_dialog.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final storage = Provider.of<StorageService>(context, listen: false);
    final shareService = Provider.of<ShareService>(context, listen: false);
    final alerts = storage.getAlerts();
    final timeFormat = DateFormat('MMM dd, yyyy • hh:mm a');

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
              // Modern Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'History',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    ),
                    const Spacer(),
                    if (alerts.isNotEmpty)
                      Material(
                        color: theme.colorScheme.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap: () async {
                            final confirm = await IOSDialog.show<bool>(
                              context: context,
                              icon: Icon(
                                Icons.delete_sweep_outlined,
                                size: 48,
                                color: theme.colorScheme.error.withOpacity(0.8),
                              ),
                              title: 'Clear All History',
                              content:
                                  'This will delete all alert records. This action cannot be undone.',
                              actions: [
                                IOSDialogAction(
                                  label: 'Cancel',
                                  returnValue: false,
                                ),
                                IOSDialogAction(
                                  label: 'Clear All',
                                  returnValue: true,
                                  isDestructive: true,
                                  isPrimary: true,
                                ),
                              ],
                            );

                            if (confirm == true) {
                              await storage.clearAllAlerts();
                              setState(() {});
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete_sweep,
                                  size: 18,
                                  color: theme.colorScheme.error,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: alerts.isEmpty
                    ? Center(
                        child: Container(
                          margin: const EdgeInsets.all(40),
                          padding: const EdgeInsets.all(40),
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: theme.textTheme.bodyMedium?.color
                                    ?.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No alerts yet',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Your panic alert history\nwill appear here',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.textTheme.bodySmall?.color
                                      ?.withOpacity(0.6),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: alerts.length,
                        itemBuilder: (context, index) {
                          final alert = alerts[index];

                          return Dismissible(
                            key: Key(alert.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await IOSDialog.show<bool>(
                                context: context,
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 48,
                                  color: theme.colorScheme.error.withOpacity(0.8),
                                ),
                                title: 'Delete Alert',
                                content: 'Delete this alert from history?',
                                actions: [
                                  IOSDialogAction(
                                    label: 'Cancel',
                                    returnValue: false,
                                  ),
                                  IOSDialogAction(
                                    label: 'Delete',
                                    returnValue: true,
                                    isDestructive: true,
                                    isPrimary: true,
                                  ),
                                ],
                              );
                            },
                            onDismissed: (direction) async {
                              await storage.deleteAlert(alert.id);
                              setState(() {});
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
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
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    try {
                                      await shareService.openMapsUrl(alert.mapsUrl);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text('Could not open maps: $e')),
                                        );
                                      }
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: alert.isResolved
                                                    ? const Color(0xFF10B981).withOpacity(0.15)
                                                    : theme.colorScheme.primary.withOpacity(0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                alert.isResolved
                                                    ? Icons.check_circle
                                                    : Icons.warning_amber_rounded,
                                                color: alert.isResolved
                                                    ? const Color(0xFF10B981)
                                                    : theme.colorScheme.primary,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                timeFormat.format(alert.createdAt),
                                                style: theme.textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (alert.isResolved)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 10,
                                                  vertical: 6,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF10B981)
                                                      .withOpacity(0.15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Text(
                                                  'Resolved',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF10B981),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 16,
                                              color: theme.textTheme.bodySmall?.color
                                                  ?.withOpacity(0.6),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                alert.locationSnippet,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  color: theme.textTheme.bodySmall?.color
                                                      ?.withOpacity(0.7),
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 14,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
