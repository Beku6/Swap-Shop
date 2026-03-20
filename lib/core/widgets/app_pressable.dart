import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppPressableHaptic { none, light, medium }

class AppPressable extends StatefulWidget {
  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.haptic = AppPressableHaptic.none,
    this.minHitTarget = 44,
    this.borderRadius,
    this.customBorder,
    this.splashColor,
    this.highlightColor,
    this.pressedScale = 0.985,
    this.downDuration = const Duration(milliseconds: 100),
    this.upDuration = const Duration(milliseconds: 180),
    this.curve = Curves.easeOutCubic,
  });

  final Widget child;
  final VoidCallback? onTap;
  final AppPressableHaptic haptic;
  final double minHitTarget;
  final BorderRadius? borderRadius;
  final ShapeBorder? customBorder;
  final Color? splashColor;
  final Color? highlightColor;
  final double pressedScale;
  final Duration downDuration;
  final Duration upDuration;
  final Curve curve;

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  Future<void> _runHaptic() {
    switch (widget.haptic) {
      case AppPressableHaptic.none:
        return Future<void>.value();
      case AppPressableHaptic.light:
        return HapticFeedback.lightImpact();
      case AppPressableHaptic.medium:
        return HapticFeedback.mediumImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    final shape =
        widget.customBorder ??
        (widget.borderRadius != null
            ? RoundedRectangleBorder(borderRadius: widget.borderRadius!)
            : null);
    final splash =
        widget.splashColor ??
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08);
    final highlight = widget.highlightColor ?? splash.withValues(alpha: 0.6);

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: widget.minHitTarget,
        minHeight: widget.minHitTarget,
      ),
      child: Material(
        color: Colors.transparent,
        shape: shape,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  _runHaptic();
                  onTap();
                },
          customBorder: shape,
          borderRadius: widget.borderRadius,
          splashColor: splash,
          highlightColor: highlight,
          onTapDown: (_) => _setPressed(true),
          onTapCancel: () => _setPressed(false),
          onTapUp: (_) => _setPressed(false),
          child: Center(
            child: AnimatedScale(
              scale: _isPressed ? widget.pressedScale : 1,
              duration: _isPressed ? widget.downDuration : widget.upDuration,
              curve: widget.curve,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
