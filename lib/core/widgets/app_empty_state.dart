import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import 'app_pressable.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool enableHaptic;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.enableHaptic = false,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedEmptyState(
      icon: icon,
      title: title,
      subtitle: subtitle,
      actionLabel: actionLabel,
      onAction: onAction,
      enableHaptic: enableHaptic,
    );
  }
}

class _AnimatedEmptyState extends StatefulWidget {
  const _AnimatedEmptyState({
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    required this.enableHaptic,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool enableHaptic;

  @override
  State<_AnimatedEmptyState> createState() => _AnimatedEmptyStateState();
}

class _AnimatedEmptyStateState extends State<_AnimatedEmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _offsetY;
  bool _didHaptic = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _opacity = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    _offsetY = Tween<double>(begin: 8, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    _controller.forward();
    _triggerHapticIfNeeded();
  }

  @override
  void didUpdateWidget(covariant _AnimatedEmptyState oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableHaptic && !oldWidget.enableHaptic) {
      _triggerHapticIfNeeded();
    }
  }

  void _triggerHapticIfNeeded() {
    if (!widget.enableHaptic || _didHaptic) {
      return;
    }
    _didHaptic = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HapticFeedback.selectionClick();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBg = AppColors.appBackground(context);

    final hasAction =
        widget.actionLabel != null &&
        widget.actionLabel!.isNotEmpty &&
        widget.onAction != null;

    return FadeTransition(
      opacity: _opacity,
      child: AnimatedBuilder(
        animation: _offsetY,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _offsetY.value),
            child: child,
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: appSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 32, color: appTextSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.clip,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: appTextPrimary,
              ),
            ),
            if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                widget.subtitle!,
                textAlign: TextAlign.center,
                maxLines: 3,
                softWrap: true,
                overflow: TextOverflow.clip,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: appTextSecondary.withValues(alpha: 0.8),
                ),
              ),
            ],
            if (hasAction) ...[
              const SizedBox(height: 16),
              AppPressable(
                onTap: widget.onAction,
                haptic: AppPressableHaptic.light,
                minHitTarget: 44,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: appTextPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.actionLabel!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: appBg,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
