import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/widgets/bottom_nav.dart';
import 'router/routes.dart';

class AppShell extends StatefulWidget {
  final String location;
  final Widget child;

  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final activeTab = _activeTabForLocation(widget.location);

    return Scaffold(
      backgroundColor: AppColors.appBackground(context),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final tween = Tween<double>(begin: 10, end: 0);
                  return FadeTransition(
                    opacity: animation,
                    child: AnimatedBuilder(
                      animation: animation,
                      builder: (context, _) => Transform.translate(
                        offset: Offset(0, tween.evaluate(animation)),
                        child: child,
                      ),
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(widget.location),
                  child: widget.child,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 512),
              child: BottomNav(
                activeTab: activeTab,
                onHome: () => context.go(Routes.home),
                onCart: () => context.go(Routes.cart),
                onWallet: () => context.go(Routes.wallet),
                onSell: () => context.go(Routes.sell),
                onProfile: () => context.go(Routes.profile),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _activeTabForLocation(String location) {
    if (location == Routes.cart) return 'cart';
    if (location == Routes.sell) return 'sell';
    if (location == Routes.wallet) return 'wallet';
    if (location == Routes.profile) return 'profile';
    return 'home';
  }
}
