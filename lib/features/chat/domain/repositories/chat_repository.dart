import '../../../shared/domain/models/chat_thread.dart';
import '../../../shared/domain/models/message.dart';

abstract class ChatRepository {
  Stream<List<ChatThread>> watchThreads(String userId);
  Stream<List<Message>> watchMessages(String threadId);
  Future<String> ensureThread({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
  });
  Future<void> sendMessage(Message message);
  Future<void> markThreadAsRead({
    required String userId,
    required String threadId,
  });
}
