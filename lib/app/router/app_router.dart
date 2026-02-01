import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/sell/presentation/pages/sell_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../app_shell.dart';
import 'routes.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: Routes.home,
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(
          location: state.uri.toString(),
          child: child,
        ),
        routes: [
          GoRoute(
            path: Routes.home,
            name: Routes.homeName,
            pageBuilder: (context, state) => const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: Routes.cart,
            name: Routes.cartName,
            pageBuilder: (context, state) => const NoTransitionPage(child: CartPage()),
          ),
          GoRoute(
            path: Routes.wallet,
            name: Routes.walletName,
            pageBuilder: (context, state) => const NoTransitionPage(child: WalletPage()),
          ),
          GoRoute(
            path: Routes.sell,
            name: Routes.sellName,
            pageBuilder: (context, state) => const NoTransitionPage(child: SellPage()),
          ),
          GoRoute(
            path: Routes.profile,
            name: Routes.profileName,
            pageBuilder: (context, state) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.messages,
        name: Routes.messagesName,
        pageBuilder: (context, state) {
          return CustomTransitionPage(
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            child: const MessagesPage(),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: Routes.product,
        name: Routes.productName,
        pageBuilder: (context, state) {
          final args = state.extra as ProductDetailsArgs?;
          return CustomTransitionPage(
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              final tween = Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).chain(CurveTween(curve: Curves.easeOutCubic));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
            child: ProductDetailsPage(
              product: args?.product,
              sourceMode: args?.sourceMode ?? 'explore',
            ),
          );
        },
      ),
    ],
  );
}
