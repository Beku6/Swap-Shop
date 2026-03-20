import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_value_builder.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../../core/widgets/offline_status_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../chat/presentation/pages/chat_thread_page.dart';
import '../../../chat/presentation/providers/chat_providers.dart';
import '../../../shared/domain/models/chat_thread.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final userId = ref.watch(
      authControllerProvider.select((controller) => controller.user?.id),
    );
    final isOffline = ref.watch(isOfflineProvider);

    final query = _controller.text.trim().toLowerCase();
    final threadsAsync = userId == null
        ? const AsyncValue<List<ChatThread>>.data([])
        : ref.watch(chatThreadsProvider(userId));

    return Scaffold(
      backgroundColor: appBg,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  decoration: BoxDecoration(
                    color: appBg.withValues(alpha: 0.8),
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
                            'Messages',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: appTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(fontSize: 15, color: appTextPrimary),
                        decoration: InputDecoration(
                          hintText: 'Search conversations...',
                          hintStyle: TextStyle(
                            color: appTextSecondary,
                            fontSize: 15,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 18,
                            color: appTextSecondary,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 44,
                          ),
                          filled: true,
                          fillColor: appSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AppAsyncValueBuilder<List<ChatThread>>(
                    value: threadsAsync,
                    onRetry: userId == null
                        ? null
                        : () => ref.invalidate(chatThreadsProvider(userId)),
                    loadingBuilder: (context) => ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const _ArchiveRow();
                        }
                        return const ChatListItemSkeleton();
                      },
                    ),
                    errorBuilder:
                        (context, error, stackTrace, onRetry, onReportIssue) =>
                            ListView(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                              children: [
                                const _ArchiveRow(),
                                const SizedBox(height: 12),
                                _MessagesErrorState(
                                  onRetry: onRetry,
                                  onReportIssue: onReportIssue,
                                ),
                              ],
                            ),
                    dataBuilder: (threads) {
                      final visibleChats = query.isEmpty
                          ? threads
                          : threads
                                .where(
                                  (thread) =>
                                      (thread.otherUserName ?? '')
                                          .toLowerCase()
                                          .contains(query) ||
                                      thread.lastMessage.toLowerCase().contains(
                                        query,
                                      ),
                                )
                                .toList();

                      if (visibleChats.isEmpty) {
                        return ListView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                          children: [
                            const _ArchiveRow(),
                            const SizedBox(height: 12),
                            _MessagesEmptyState(textColor: appTextSecondary),
                          ],
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                        itemCount: visibleChats.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return const _ArchiveRow();
                          }
                          final chat = visibleChats[index - 1];
                          return _ChatRow(
                            key: ValueKey<String>('chat-${chat.id}'),
                            chat: chat,
                            onTap: () => context.push(
                              Routes.chatThread,
                              extra: ChatThreadArgs(
                                threadId: chat.id,
                                title: chat.otherUserName ?? 'User',
                                avatar:
                                    chat.otherUserAvatar ??
                                    'https://api.dicebear.com/7.x/avataaars/svg?seed=${chat.otherUserId ?? chat.id}',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          OfflineStatusBanner(visible: isOffline),
        ],
      ),
    );
  }
}

class _MessagesEmptyState extends StatelessWidget {
  const _MessagesEmptyState({required this.textColor});

  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          'No conversations yet.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _MessagesErrorState extends StatelessWidget {
  const _MessagesErrorState({required this.onRetry, this.onReportIssue});

  final FutureOr<void> Function()? onRetry;
  final FutureOr<void> Function()? onReportIssue;

  @override
  Widget build(BuildContext context) {
    return AppErrorState(
      title: 'Unable to load messages',
      message: 'Please try again in a moment.',
      onRetry: onRetry,
      onReportIssue: onReportIssue,
    );
  }
}

class _ArchiveRow extends StatelessWidget {
  const _ArchiveRow();

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appSurface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: appBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: appTextPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.archive_outlined,
                  size: 18,
                  color: appTextSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Archived Chats',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: appTextSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 16,
                color: appTextSecondary.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  final ChatThread chat;
  final VoidCallback onTap;

  const _ChatRow({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    final unread = chat.unreadCount > 0;
    final avatar =
        chat.otherUserAvatar ??
        'https://api.dicebear.com/7.x/avataaars/svg?seed=${chat.otherUserId ?? chat.id}';
    final displayName = chat.otherUserName ?? 'User';

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            color: appTextPrimary.withValues(alpha: 0.05),
                            child: ImageWithFallback(
                              src: avatar,
                              cacheWidth: 168,
                              cacheHeight: 168,
                            ),
                          ),
                        ),
                        if (unread)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.blue500,
                                shape: BoxShape.circle,
                                border: Border.all(color: appBg, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${chat.unreadCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                              ),
                            ),
                            Text(
                              _formatTime(chat.updatedAt),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: appTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          chat.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: unread
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: unread
                                ? appTextPrimary.withValues(alpha: 0.9)
                                : appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
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
  if (difference.inDays < 2) return 'Yesterday';
  return '${difference.inDays}d';
}
