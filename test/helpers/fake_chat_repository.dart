import 'dart:async';

import 'package:swap/features/chat/domain/repositories/chat_repository.dart';
import 'package:swap/features/shared/domain/models/chat_thread.dart';
import 'package:swap/features/shared/domain/models/message.dart';

class FakeChatRepository implements ChatRepository {
  final Map<String, List<ChatThread>> _threadsByUser = <String, List<ChatThread>>{};
  final Map<String, List<Message>> _messagesByThread = <String, List<Message>>{};

  @override
  Stream<List<ChatThread>> watchThreads(String userId) {
    return Stream.value(_threadsByUser[userId] ?? const <ChatThread>[]);
  }

  @override
  Stream<List<Message>> watchMessages(String threadId) {
    return Stream.value(_messagesByThread[threadId] ?? const <Message>[]);
  }

  @override
  Future<String> ensureThread({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
  }) async {
    final threadId = _threadId(currentUserId, otherUserId);
    _messagesByThread.putIfAbsent(threadId, () => <Message>[]);

    _upsertThread(
      ownerId: currentUserId,
      thread: ChatThread(
        id: threadId,
        participantIds: [currentUserId, otherUserId],
        lastMessage: '',
        updatedAt: DateTime.now(),
        otherUserId: otherUserId,
        otherUserName: otherUserName ?? 'User $otherUserId',
        otherUserAvatar: otherUserAvatar,
        unreadCount: 0,
      ),
    );

    _upsertThread(
      ownerId: otherUserId,
      thread: ChatThread(
        id: threadId,
        participantIds: [currentUserId, otherUserId],
        lastMessage: '',
        updatedAt: DateTime.now(),
        otherUserId: currentUserId,
        otherUserName: 'User $currentUserId',
        otherUserAvatar: null,
        unreadCount: 0,
      ),
    );

    return threadId;
  }

  @override
  Future<void> sendMessage(Message message) async {
    String threadId = message.threadId;
    if (threadId.isEmpty) {
      final receiverId = message.receiverId;
      if (receiverId == null || receiverId.isEmpty) {
        throw StateError('receiverId required');
      }
      threadId = await ensureThread(
        currentUserId: message.senderId,
        otherUserId: receiverId,
      );
    }

    final stored = message.copyWith(
      id: message.id.isEmpty ? '${DateTime.now().microsecondsSinceEpoch}' : message.id,
      threadId: threadId,
      sentAt: DateTime.now(),
    );

    _messagesByThread.putIfAbsent(threadId, () => <Message>[]).add(stored);

    final senderThread = _getThreadForUser(message.senderId, threadId);
    final receiverId = senderThread?.otherUserId ?? message.receiverId ?? '';

    if (senderThread != null) {
      _upsertThread(
        ownerId: message.senderId,
        thread: senderThread.copyWith(
          lastMessage: stored.text,
          updatedAt: stored.sentAt,
          unreadCount: 0,
        ),
      );
    }

    if (receiverId.isNotEmpty) {
      final receiverThread = _getThreadForUser(receiverId, threadId);
      if (receiverThread != null) {
        _upsertThread(
          ownerId: receiverId,
          thread: receiverThread.copyWith(
            lastMessage: stored.text,
            updatedAt: stored.sentAt,
            unreadCount: receiverThread.unreadCount + 1,
          ),
        );
      }
    }
  }

  @override
  Future<void> markThreadAsRead({required String userId, required String threadId}) async {
    final thread = _getThreadForUser(userId, threadId);
    if (thread == null) return;
    _upsertThread(ownerId: userId, thread: thread.copyWith(unreadCount: 0));
  }

  ChatThread? _getThreadForUser(String userId, String threadId) {
    final threads = _threadsByUser[userId] ?? const <ChatThread>[];
    for (final thread in threads) {
      if (thread.id == threadId) return thread;
    }
    return null;
  }

  void _upsertThread({required String ownerId, required ChatThread thread}) {
    final list = _threadsByUser.putIfAbsent(ownerId, () => <ChatThread>[]);
    final index = list.indexWhere((entry) => entry.id == thread.id);
    if (index == -1) {
      list.add(thread);
    } else {
      list[index] = thread;
    }
  }

  String _threadId(String first, String second) {
    final sorted = [first, second]..sort();
    return '${sorted.first}_${sorted.last}';
  }
}
