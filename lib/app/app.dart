import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../core/theme/theme_providers.dart';
import '../core/widgets/image_with_fallback.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/notifications/presentation/providers/notifications_providers.dart';
import '../features/sell/presentation/providers/publish_job_provider.dart';
import '../core/observability/observability_providers.dart';
import 'router/app_router.dart';

class SwapApp extends ConsumerStatefulWidget {
  const SwapApp({super.key});

  static const bool _enablePerfOverlay = bool.fromEnvironment(
    'PERF_OVERLAY',
    defaultValue: false,
  );
  static const bool _enableCheckerboardRaster = bool.fromEnvironment(
    'CHECKERBOARD_RASTER',
    defaultValue: false,
  );
  static const bool _enableCheckerboardOffscreen = bool.fromEnvironment(
    'CHECKERBOARD_OFFSCREEN',
    defaultValue: false,
  );

  @override
  ConsumerState<SwapApp> createState() => _SwapAppState();
}

class _SwapAppState extends ConsumerState<SwapApp> with WidgetsBindingObserver {
  ProviderSubscription<AuthController>? _authSubscription;
  bool _postFrameTasksScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _authSubscription = ref.listenManual<AuthController>(
      authControllerProvider,
      (previous, next) async {
        await _syncUserBindings(next.user?.id);
      },
      fireImmediately: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _postFrameTasksScheduled) {
        return;
      }
      _postFrameTasksScheduled = true;
      await _runPostFrameStartupTasks();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.close();
    ref.read(pushNotificationServiceProvider).dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(publishJobProvider.notifier).onAppResumed();
    }
  }

  Future<void> _syncUserBindings(String? userId) async {
    try {
      await ref.read(pushNotificationServiceProvider).bindUser(userId);
    } catch (_) {}
    try {
      await ref
          .read(firebaseCrashlyticsProvider)
          .setUserIdentifier(userId ?? '');
    } catch (_) {}
  }

  Future<void> _runPostFrameStartupTasks() async {
    if (!mounted) {
      return;
    }
    try {
      await _precacheStartupImages();
    } catch (_) {}
    try {
      await _initializePushService();
    } catch (_) {}
  }

  Future<void> _precacheStartupImages() async {
    if (!mounted) {
      return;
    }
    await precacheImage(ImageWithFallback.errorImageProvider, context);
  }

  Future<void> _initializePushService() async {
    final service = ref.read(pushNotificationServiceProvider);
    await service.initialize();
    await service.bindUser(ref.read(authControllerProvider).user?.id);
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ref.watch(themeControllerProvider);
    return MaterialApp.router(
      title: 'Swap',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.mode,
      themeAnimationDuration: const Duration(milliseconds: 240),
      themeAnimationCurve: Curves.easeInOutCubic,
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
      showPerformanceOverlay: SwapApp._enablePerfOverlay && !kReleaseMode,
      checkerboardRasterCacheImages:
          SwapApp._enableCheckerboardRaster && !kReleaseMode,
      checkerboardOffscreenLayers:
          SwapApp._enableCheckerboardOffscreen && !kReleaseMode,
      scrollBehavior: const _NoScrollbarBehavior(),
      builder: (context, child) {
        return ColoredBox(
          color: const Color(0xFFF3F0EB),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _NoScrollbarBehavior extends ScrollBehavior {
  const _NoScrollbarBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
