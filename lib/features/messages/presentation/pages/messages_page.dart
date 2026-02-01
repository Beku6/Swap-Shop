import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final TextEditingController _controller = TextEditingController();

  final List<_Conversation> _chats = const [
    _Conversation(
      id: '1',
      name: 'Sarah J.',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
      lastMessage: 'Is the iPhone still available for swap? I have a Sony A7III.',
      time: '2m ago',
      unreadCount: 2,
    ),
    _Conversation(
      id: '2',
      name: 'Marcus W.',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus',
      lastMessage: 'The sneakers look great in person. Thanks!',
      time: '1h ago',
      unreadCount: 0,
    ),
    _Conversation(
      id: '3',
      name: 'Elena R.',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elena',
      lastMessage: 'Sent the shipping details for the Leica.',
      time: '3h ago',
      unreadCount: 1,
    ),
    _Conversation(
      id: '4',
      name: 'Julian B.',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Julian',
      lastMessage: 'Can we meet halfway for the chair?',
      time: 'Yesterday',
      unreadCount: 0,
    ),
    _Conversation(
      id: '5',
      name: 'Sophia L.',
      avatar: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
      lastMessage: 'That watch is incredible. Do you accept USDT?',
      time: '2 days ago',
      unreadCount: 0,
    ),
  ];

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
    final appBorder = AppColors.appBorder(context);

    final query = _controller.text.trim().toLowerCase();
    final visibleChats = query.isEmpty
        ? _chats
        : _chats
            .where((chat) =>
                chat.name.toLowerCase().contains(query) ||
                chat.lastMessage.toLowerCase().contains(query))
            .toList();

    return Scaffold(
      backgroundColor: appBg,
      body: SafeArea(
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
                          child: Icon(Icons.arrow_back, size: 20, color: appTextSecondary),
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
                      hintStyle: TextStyle(color: appTextSecondary, fontSize: 15),
                      prefixIcon: Icon(Icons.search, size: 18, color: appTextSecondary),
                      prefixIconConstraints: const BoxConstraints(minWidth: 44),
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    GestureDetector(
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
                              child: Icon(Icons.archive_outlined,
                                  size: 18, color: appTextSecondary),
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
                            Icon(Icons.chevron_right, size: 16, color: appTextSecondary.withValues(alpha: 0.4)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final chat in visibleChats) _ChatRow(chat: chat),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  final _Conversation chat;

  const _ChatRow({required this.chat});

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    final unread = chat.unreadCount > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () {},
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
                          child: ImageWithFallback(src: chat.avatar),
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
                            chat.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: appTextPrimary,
                            ),
                          ),
                          Text(
                            chat.time,
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
                          fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                          color: unread ? appTextPrimary.withValues(alpha: 0.9) : appTextSecondary,
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
    );
  }
}

class _Conversation {
  final String id;
  final String name;
  final String avatar;
  final String lastMessage;
  final String time;
  final int unreadCount;

  const _Conversation({
    required this.id,
    required this.name,
    required this.avatar,
    required this.lastMessage,
    required this.time,
    required this.unreadCount,
  });
}
