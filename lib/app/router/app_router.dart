import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/cart/presentation/pages/cart_page.dart';
import '../../features/chat/presentation/pages/chat_thread_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/product/presentation/pages/product_details_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/sell/presentation/pages/sell_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';
import '../../features/settings/presentation/pages/account_page.dart';
import '../../features/settings/presentation/pages/danger_zone_page.dart';
import '../../features/settings/presentation/pages/notifications_settings_page.dart';
import '../../features/settings/presentation/pages/privacy_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../app_shell.dart';
import 'routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.watch(authControllerProvider);
  final rootKey = GlobalKey<NavigatorState>();
  final shellKey = GlobalKey<NavigatorState>();

  CustomTransitionPage<void> buildFadeThroughPage(Widget child) {
    return CustomTransitionPage<void>(
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  CustomTransitionPage<void> buildAuthFadePage(Widget child) {
    return CustomTransitionPage<void>(
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
          reverseCurve: Curves.easeInOutCubic,
        );
        return FadeTransition(opacity: curved, child: child);
      },
      child: child,
    );
  }

  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: Routes.home,
    refreshListenable: authController,
    redirect: (context, state) {
      if (!authController.isInitialized) {
        return null;
      }
      final isAuthed = authController.user != null;
      final location = state.matchedLocation;
      final isWelcome = location == Routes.welcome;
      final isAuthRoute =
          isWelcome ||
          location == Routes.signIn ||
          location == Routes.register ||
          location == Routes.forgotPassword;

      if (!isAuthed) {
        if (!isAuthRoute) {
          return Routes.welcome;
        }
        return null;
      }

      if (isAuthed && isAuthRoute) {
        return Routes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: Routes.welcome,
        name: Routes.welcomeName,
        pageBuilder: (context, state) => buildAuthFadePage(const WelcomePage()),
      ),
      GoRoute(
        path: Routes.signIn,
        name: Routes.signInName,
        pageBuilder: (context, state) => buildAuthFadePage(const SignInPage()),
      ),
      GoRoute(
        path: Routes.register,
        name: Routes.registerName,
        pageBuilder: (context, state) =>
            buildAuthFadePage(const RegisterPage()),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        name: Routes.forgotPasswordName,
        pageBuilder: (context, state) =>
            buildAuthFadePage(const ForgotPasswordPage()),
      ),
      ShellRoute(
        navigatorKey: shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.uri.toString(), child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            name: Routes.homeName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
          ),
          GoRoute(
            path: Routes.cart,
            name: Routes.cartName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: CartPage()),
          ),
          GoRoute(
            path: Routes.wallet,
            name: Routes.walletName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: WalletPage()),
          ),
          GoRoute(
            path: Routes.sell,
            name: Routes.sellName,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: SellPage()),
          ),
          GoRoute(
            path: Routes.profile,
            name: Routes.profileName,
            pageBuilder: (context, state) => NoTransitionPage(
              child: ProfilePage(ownerId: state.extra as String?),
            ),
          ),
        ],
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: Routes.messages,
        name: Routes.messagesName,
        pageBuilder: (context, state) =>
            buildFadeThroughPage(const MessagesPage()),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: Routes.chatThread,
        name: Routes.chatThreadName,
        pageBuilder: (context, state) {
          final args = state.extra as ChatThreadArgs?;
          return CustomTransitionPage(
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  final tween = Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).chain(CurveTween(curve: Curves.easeOutCubic));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
            child: ChatThreadPage(
              args:
                  args ??
                  const ChatThreadArgs(
                    threadId: '',
                    title: 'Chat',
                    avatar:
                        'https://api.dicebear.com/7.x/avataaars/svg?seed=chat',
                  ),
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: Routes.notifications,
        name: Routes.notificationsName,
        pageBuilder: (context, state) =>
            buildFadeThroughPage(const NotificationsPage()),
      ),
      GoRoute(
        parentNavigatorKey: rootKey,
        path: Routes.product,
        name: Routes.productName,
        pageBuilder: (context, state) {
          final args = state.extra as ProductDetailsArgs?;
          return buildFadeThroughPage(
            ProductDetailsPage(
              productId: args?.productId ?? '',
              product: args?.product,
              sourceMode: args?.sourceMode ?? 'explore',
            ),
          );
        },
      ),
      GoRoute(
        path: Routes.settings,
        name: Routes.settingsName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SettingsPage()),
      ),
      GoRoute(
        path: Routes.settingsAccount,
        name: Routes.settingsAccountName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AccountPage()),
      ),
      GoRoute(
        path: Routes.settingsNotifications,
        name: Routes.settingsNotificationsName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: NotificationsSettingsPage()),
      ),
      GoRoute(
        path: Routes.settingsPrivacy,
        name: Routes.settingsPrivacyName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: PrivacyPage()),
      ),
      GoRoute(
        path: Routes.settingsAbout,
        name: Routes.settingsAboutName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: AboutPage()),
      ),
      GoRoute(
        path: Routes.settingsDangerZone,
        name: Routes.settingsDangerZoneName,
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: DangerZonePage()),
      ),
    ],
  );
});
