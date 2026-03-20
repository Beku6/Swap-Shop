import 'dart:async';

import 'package:flutter/material.dart';

class AppDelayedLoading extends StatefulWidget {
  const AppDelayedLoading({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 120),
    this.fadeInDuration = const Duration(milliseconds: 150),
    this.fadeOutDuration = const Duration(milliseconds: 120),
  });

  final Widget child;
  final Duration delay;
  final Duration fadeInDuration;
  final Duration fadeOutDuration;

  @override
  State<AppDelayedLoading> createState() => _AppDelayedLoadingState();
}

class _AppDelayedLoadingState extends State<AppDelayedLoading> {
  Timer? _delayTimer;
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _delayTimer = Timer(widget.delay, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1 : 0,
      duration: _isVisible ? widget.fadeInDuration : widget.fadeOutDuration,
      curve: Curves.easeOutCubic,
      child: widget.child,
    );
  }
}
