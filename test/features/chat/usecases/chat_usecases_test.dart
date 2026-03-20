import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/chat/domain/usecases/ensure_thread.dart';
import 'package:swap/features/chat/domain/usecases/mark_thread_as_read.dart';
import 'package:swap/features/chat/domain/usecases/send_message.dart';
import 'package:swap/features/chat/domain/usecases/watch_messages.dart';
import 'package:swap/features/chat/domain/usecases/watch_threads.dart';
import 'package:swap/features/shared/domain/models/message.dart';

import '../../../helpers/fake_chat_repository.dart';

void main() {
  test('ensure thread creates a thread for both users', () async {
    final repo = FakeChatRepository();
    final usecase = EnsureThread(repo);

    final threadId = await usecase(
      currentUserId: 'u1',
      otherUserId: 'u2',
      otherUserName: 'User 2',
    );

    final threads = await WatchThreads(repo).call('u1').first;
    expect(threadId, isNotEmpty);
    expect(threads.length, 1);
    expect(threads.first.otherUserId, 'u2');
  });

  test('send message stores message and updates thread preview', () async {
    final repo = FakeChatRepository();
    final threadId = await EnsureThread(repo)(currentUserId: 'u1', otherUserId: 'u2');

    await SendMessage(repo).call(
      Message(
        id: '',
        threadId: threadId,
        senderId: 'u1',
        text: 'hello',
        sentAt: DateTime.now(),
        isRead: false,
      ),
    );

    final messages = await WatchMessages(repo).call(threadId).first;
    final threads = await WatchThreads(repo).call('u2').first;
    expect(messages.length, 1);
    expect(threads.first.lastMessage, 'hello');
    expect(threads.first.unreadCount, 1);
  });

  test('mark thread as read resets unread count', () async {
    final repo = FakeChatRepository();
    final threadId = await EnsureThread(repo)(currentUserId: 'u1', otherUserId: 'u2');
    await SendMessage(repo).call(
      Message(
        id: '',
        threadId: threadId,
        senderId: 'u1',
        text: 'ping',
        sentAt: DateTime.now(),
        isRead: false,
      ),
    );

    await MarkThreadAsRead(repo).call(userId: 'u2', threadId: threadId);
    final threads = await WatchThreads(repo).call('u2').first;
    expect(threads.first.unreadCount, 0);
  });
}
