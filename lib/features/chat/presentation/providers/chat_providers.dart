import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/observability_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../shared/domain/models/chat_thread.dart';
import '../../../shared/domain/models/message.dart';
import '../../data/firebase_chat_repository.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../domain/usecases/ensure_thread.dart';
import '../../domain/usecases/mark_thread_as_read.dart';
import '../../domain/usecases/send_message.dart';
import '../../domain/usecases/watch_messages.dart';
import '../../domain/usecases/watch_threads.dart';

final chatFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository(
    ref.watch(chatFirestoreProvider),
    ref.watch(notificationRepositoryProvider),
    ref.watch(appAnalyticsProvider),
  );
});

final watchThreadsProvider = Provider<WatchThreads>((ref) {
  return WatchThreads(ref.watch(chatRepositoryProvider));
});

final watchMessagesProvider = Provider<WatchMessages>((ref) {
  return WatchMessages(ref.watch(chatRepositoryProvider));
});

final sendMessageProvider = Provider<SendMessage>((ref) {
  return SendMessage(ref.watch(chatRepositoryProvider));
});

final ensureThreadProvider = Provider<EnsureThread>((ref) {
  return EnsureThread(ref.watch(chatRepositoryProvider));
});

final markThreadAsReadProvider = Provider<MarkThreadAsRead>((ref) {
  return MarkThreadAsRead(ref.watch(chatRepositoryProvider));
});

final chatThreadsProvider = StreamProvider.family<List<ChatThread>, String>((
  ref,
  userId,
) {
  final currentUserId = ref.watch(authControllerProvider).user?.id;
  if (currentUserId == null || currentUserId != userId) {
    return Stream.value(const <ChatThread>[]);
  }
  return ref.watch(watchThreadsProvider).call(userId);
});

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  threadId,
) {
  return ref.watch(watchMessagesProvider).call(threadId);
});
