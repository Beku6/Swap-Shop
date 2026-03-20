import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_value_builder.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../shared/domain/models/app_notification.dart';
import '../providers/notifications_providers.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _activeFilter = 'all';

  static const List<String> _filters = <String>[
    'all',
    'offer',
    'message',
    'activity',
  ];

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    final userId = ref.watch(
      authControllerProvider.select((controller) => controller.user?.id),
    );
    final notificationsAsync = userId == null
        ? const AsyncValue<List<AppNotification>>.data(<AppNotification>[])
        : ref.watch(notificationsProvider(userId));
    final notifications = notificationsAsync.value ?? const <AppNotification>[];
    final filtered = _activeFilter == 'all'
        ? notifications
        : notifications.where((item) => item.type == _activeFilter).toList();

    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              decoration: BoxDecoration(
                color: appBg.withValues(alpha: 0.8),
                border: Border(bottom: BorderSide(color: appBorder)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: appBorder),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 20,
                            color: appTextSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Notifications',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: appTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final filter = _filters[index];
                        final isActive = _activeFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _activeFilter = filter),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isActive ? appTextPrimary : appSurface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: isActive ? appTextPrimary : appBorder,
                              ),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isActive ? appBg : appTextSecondary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppAsyncValueBuilder<List<AppNotification>>(
                value: notificationsAsync,
                onRetry: userId == null
                    ? null
                    : () => ref.invalidate(notificationsProvider(userId)),
                errorTitle: 'Unable to load notifications',
                loadingBuilder: (context) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  itemCount: 8,
                  itemBuilder: (context, index) =>
                      const NotificationItemSkeleton(),
                ),
                dataBuilder: (_) {
                  if (filtered.isEmpty) {
                    return _EmptyState(
                      textColor: appTextSecondary,
                      iconColor: appBorder,
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final notification = filtered[index];
                      return _NotificationTile(
                        key: ValueKey<String>('notif-${notification.id}'),
                        notification: notification,
                        onTap: () => _markReadIfNeeded(userId, notification),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markReadIfNeeded(
    String? userId,
    AppNotification notification,
  ) async {
    if (userId == null || notification.isRead) return;
    await ref
        .read(markNotificationReadProvider)
        .call(userId: userId, notificationId: notification.id);
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    final isRead = notification.isRead;
    final badgeColor = switch (notification.type) {
      'offer' => AppColors.blue500,
      'message' => AppColors.violet500,
      _ => AppColors.emerald500,
    };
    final badgeIcon = switch (notification.type) {
      'offer' => Icons.swap_horiz_rounded,
      'message' => Icons.message_rounded,
      _ => Icons.favorite,
    };

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isRead ? 0.7 : 1,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isRead ? appSurface.withValues(alpha: 0.3) : appSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: appBorder),
                  boxShadow: isRead
                      ? null
                      : [
                          BoxShadow(
                            color: appTextPrimary.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: appBorder),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: ImageWithFallback(
                          src: _avatarSeedFor(notification),
                          cacheWidth: 144,
                          cacheHeight: 144,
                        ),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: badgeColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: appSurface, width: 2),
                          ),
                          child: Icon(
                            badgeIcon,
                            size: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: appTextPrimary,
                                ),
                              ),
                            ),
                            Text(
                              _formatTime(notification.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: appTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          notification.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.4,
                            color: appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isRead) ...[
                    const SizedBox(width: 10),
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: const BoxDecoration(
                        color: AppColors.blue500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _avatarSeedFor(AppNotification notification) {
    final imageUrl = notification.data['imageUrl'];
    if (imageUrl is String && imageUrl.isNotEmpty) {
      return imageUrl;
    }
    final seed =
        notification.data['senderId'] ??
        notification.data['actorId'] ??
        notification.id;
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$seed';
  }
}

class _EmptyState extends StatelessWidget {
  final Color textColor;
  final Color iconColor;

  const _EmptyState({required this.textColor, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: iconColor),
              ),
              child: Icon(
                Icons.notifications_none,
                size: 32,
                color: textColor.withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'All clear!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't have any notifications in this category.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: textColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  if (difference.inMinutes < 1) return 'now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m';
  if (difference.inHours < 24) return '${difference.inHours}h';
  if (difference.inDays < 2) return '1d';
  return '${difference.inDays}d';
}
