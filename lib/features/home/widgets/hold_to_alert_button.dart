import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../../core/models/alert_event.dart';

enum ButtonMode {
  panic,
  allClear,
}

class HoldToAlertButton extends StatefulWidget {
  final VoidCallback onAlertTriggered;
  final VoidCallback? onAllClearTriggered;
  final AlertEvent? activeAlert;
  final Duration holdDuration;

  const HoldToAlertButton({
    Key? key,
    required this.onAlertTriggered,
    this.onAllClearTriggered,
    this.activeAlert,
    this.holdDuration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<HoldToAlertButton> createState() => _HoldToAlertButtonState();
}

class _HoldToAlertButtonState extends State<HoldToAlertButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  Timer? _holdTimer;
  late AnimationController _progressController;

  ButtonMode get _mode =>
      widget.activeAlert != null ? ButtonMode.allClear : ButtonMode.panic;

  Color get _buttonColor {
    final theme = Theme.of(context);
    if (_mode == ButtonMode.allClear) {
      return const Color(0xFF10B981); // Green for all clear
    }
    return theme.colorScheme.primary; // Red for panic
  }

  String get _buttonText {
    if (_mode == ButtonMode.allClear) {
      return _isPressed ? 'HOLD...' : 'HOLD TO SEND\nALL CLEAR';
    }
    return _isPressed ? 'HOLD...' : 'HOLD TO\nALERT';
  }

  IconData get _buttonIcon {
    return _mode == ButtonMode.allClear
        ? Icons.check_circle_outline
        : Icons.warning_rounded;
  }

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: widget.holdDuration,
    );

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onHoldComplete();
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  void _onPressStart() {
    setState(() {
      _isPressed = true;
    });

    HapticFeedback.mediumImpact();
    _progressController.forward(from: 0);
  }

  void _onPressEnd() {
    if (_isPressed && _progressController.status != AnimationStatus.completed) {
      setState(() {
        _isPressed = false;
      });

      _progressController.reverse();
      HapticFeedback.lightImpact();
    }
  }

  void _onHoldComplete() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isPressed = false;
    });
    _progressController.reset();

    if (_mode == ButtonMode.allClear) {
      widget.onAllClearTriggered?.call();
    } else {
      widget.onAlertTriggered();
    }
  }

  @override
  Widget build(BuildContext context) {
    const size = 240.0;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onLongPressStart: (_) => _onPressStart(),
      onLongPressEnd: (_) => _onPressEnd(),
      child: AnimatedBuilder(
        animation: _progressController,
        builder: (context, child) {
          return AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _buttonColor,
                boxShadow: [
                  BoxShadow(
                    color: _buttonColor.withOpacity(_isPressed ? 0.6 : 0.4),
                    blurRadius: _isPressed ? 40 : 25,
                    spreadRadius: _isPressed ? 8 : 2,
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring decoration
                  Container(
                    width: size - 10,
                    height: size - 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                  ),

                  // Progress ring
                  if (_isPressed)
                    SizedBox(
                      width: size - 30,
                      height: size - 30,
                      child: CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 8,
                        strokeCap: StrokeCap.round,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                  // Button content
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _buttonIcon,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _buttonText,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          height: 1.3,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
