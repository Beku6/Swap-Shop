import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_error_mapper.dart';
import '../../../../core/utils/app_error_reporter.dart';
import '../../../../core/widgets/app_async_value_builder.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../shared/domain/models/message.dart';
import '../providers/chat_providers.dart';

class ChatThreadArgs {
  final String threadId;
  final String title;
  final String avatar;

  const ChatThreadArgs({
    required this.threadId,
    required this.title,
    required this.avatar,
  });
}

class ChatThreadPage extends ConsumerStatefulWidget {
  final ChatThreadArgs args;

  const ChatThreadPage({super.key, required this.args});

  @override
  ConsumerState<ChatThreadPage> createState() => _ChatThreadPageState();
}

class _ChatThreadPageState extends ConsumerState<ChatThreadPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId == null) return;
      ref
          .read(markThreadAsReadProvider)
          .call(userId: userId, threadId: widget.args.threadId)
          .catchError((error, stackTrace) {
            return AppErrorReporter.report(
              error: error,
              stackTrace: stackTrace is StackTrace
                  ? stackTrace
                  : StackTrace.current,
              reason: 'chat_mark_read_failed',
              context: <String, Object?>{
                'threadId': widget.args.threadId,
                'userId': userId,
              },
            );
          });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final isOffline = ref.read(isOfflineProvider);
    if (isOffline) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You\'re offline. Connect to send messages.'),
        ),
      );
      return;
    }

    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await ref
          .read(sendMessageProvider)
          .call(
            Message(
              id: '',
              threadId: widget.args.threadId,
              senderId: user.id,
              text: text,
              sentAt: DateTime.now(),
              isRead: false,
            ),
          );
      _controller.clear();
    } catch (error, stackTrace) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppErrorMapper.map(error))));
      await AppErrorReporter.report(
        error: error,
        stackTrace: stackTrace,
        reason: 'chat_send_message_failed',
      );
    }
  }

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
    final messagesAsync = ref.watch(chatMessagesProvider(widget.args.threadId));

    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
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
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: ImageWithFallback(
                        src: widget.args.avatar,
                        cacheWidth: 120,
                        cacheHeight: 120,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.args.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: appTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AppAsyncValueBuilder<List<Message>>(
                value: messagesAsync,
                onRetry: () =>
                    ref.invalidate(chatMessagesProvider(widget.args.threadId)),
                errorTitle: 'Unable to load conversation',
                loadingBuilder: (context) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  itemCount: 6,
                  itemBuilder: (context, index) => Align(
                    alignment: index.isEven
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      width: 180,
                      child: const AppSkeletonBlock(height: 42, radius: 16),
                    ),
                  ),
                ),
                dataBuilder: (messages) => ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - 1 - index];
                    final isMine = userId == message.senderId;
                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMine ? AppColors.white : appSurface,
                          borderRadius: BorderRadius.circular(16),
                          border: isMine ? null : Border.all(color: appBorder),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            color: isMine ? AppColors.black : appTextPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(fontSize: 14, color: appTextPrimary),
                      decoration: InputDecoration(
                        hintText: 'Write a message...',
                        hintStyle: TextStyle(
                          color: appTextSecondary,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: appSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppPressable(
                    onTap: _sendMessage,
                    haptic: AppPressableHaptic.medium,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.send,
                        size: 18,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
