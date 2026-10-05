import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

class IOSDialog {
  /// Shows a modern iOS-style alert dialog with blur effect
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required String content,
    List<IOSDialogAction>? actions,
    Widget? icon,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            ).drive(Tween<double>(begin: 0.95, end: 1.0)),
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: _IOSDialogContent(
            title: title,
            content: content,
            actions: actions ?? [],
            icon: icon,
          ),
        );
      },
    );
  }

  /// Shows an iOS-style action sheet (bottom sheet) for destructive actions
  static Future<T?> showActionSheet<T>({
    required BuildContext context,
    String? title,
    String? message,
    required List<IOSActionSheetAction> actions,
    String? cancelLabel,
  }) {
    return showCupertinoModalPopup<T>(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: title != null
              ? Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.08,
                  ),
                )
              : null,
          message: message != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.08,
                    ),
                  ),
                )
              : null,
          actions: actions
              .map((action) => CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context, action.returnValue);
                    },
                    isDestructiveAction: action.isDestructive,
                    child: Text(action.label),
                  ))
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, null),
            isDefaultAction: true,
            child: Text(cancelLabel ?? 'Cancel'),
          ),
        );
      },
    );
  }
}

class _IOSDialogContent extends StatelessWidget {
  final String? title;
  final String content;
  final List<IOSDialogAction> actions;
  final Widget? icon;

  const _IOSDialogContent({
    this.title,
    required this.content,
    required this.actions,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.light
                  ? Colors.white.withOpacity(0.95)
                  : Colors.grey[900]!.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.brightness == Brightness.light
                    ? Colors.black.withOpacity(0.1)
                    : Colors.white.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (icon != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: icon!,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (title != null) ...[
                      Text(
                        title!,
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 14,
                        height: 1.4,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    _buildActions(context, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context, ThemeData theme) {
    if (actions.isEmpty) return const SizedBox.shrink();

    if (actions.length == 1) {
      return _buildSingleAction(context, theme, actions.first);
    }

    if (actions.length == 2) {
      return Row(
        children: [
          Expanded(
            child: _buildAction(context, theme, actions[0], isSecondary: true),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildAction(context, theme, actions[1]),
          ),
        ],
      );
    }

    return Column(
      children: actions.map((action) {
        final isLast = action == actions.last;
        return Padding(
          padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
          child: _buildSingleAction(context, theme, action),
        );
      }).toList(),
    );
  }

  Widget _buildSingleAction(
      BuildContext context, ThemeData theme, IOSDialogAction action) {
    return SizedBox(
      width: double.infinity,
      child: _buildAction(context, theme, action),
    );
  }

  Widget _buildAction(
    BuildContext context,
    ThemeData theme,
    IOSDialogAction action, {
    bool isSecondary = false,
  }) {
    final isPrimary = action.isPrimary && !isSecondary;
    final isDestructive = action.isDestructive;

    Color backgroundColor;
    Color textColor;

    if (isDestructive) {
      backgroundColor = isSecondary
          ? Colors.transparent
          : theme.colorScheme.error.withOpacity(0.1);
      textColor = theme.colorScheme.error;
    } else if (isPrimary) {
      backgroundColor = theme.colorScheme.primary;
      textColor = Colors.white;
    } else {
      backgroundColor = theme.brightness == Brightness.light
          ? Colors.grey[100]!
          : Colors.grey[800]!;
      textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    }

    if (isSecondary && !isDestructive) {
      backgroundColor = Colors.transparent;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(action.returnValue),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: isSecondary
                ? Border.all(
                    color: isDestructive
                        ? theme.colorScheme.error.withOpacity(0.3)
                        : theme.brightness == Brightness.light
                            ? Colors.grey[300]!
                            : Colors.grey[700]!,
                    width: 1.5,
                  )
                : null,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Text(
            action.label,
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w500,
              letterSpacing: -0.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class IOSDialogAction {
  final String label;
  final dynamic returnValue;
  final bool isPrimary;
  final bool isDestructive;

  const IOSDialogAction({
    required this.label,
    this.returnValue,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}

class IOSActionSheetAction {
  final String label;
  final dynamic returnValue;
  final bool isDestructive;

  const IOSActionSheetAction({
    required this.label,
    this.returnValue,
    this.isDestructive = false,
  });
}
