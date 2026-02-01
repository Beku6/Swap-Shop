import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import 'router/app_router.dart';

class SwapApp extends StatelessWidget {
  const SwapApp({super.key});

  static const bool _enablePerfOverlay = bool.fromEnvironment('PERF_OVERLAY', defaultValue: false);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Swap',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeController.instance.mode,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeOut,
          routerConfig: AppRouter.router,
          debugShowCheckedModeBanner: false,
          showPerformanceOverlay: _enablePerfOverlay && !kReleaseMode,
          scrollBehavior: const _NoScrollbarBehavior(),
        );
      },
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
