import '../../../shared/domain/models/chat_thread.dart';
import '../repositories/chat_repository.dart';

class WatchThreads {
  final ChatRepository _repository;

  const WatchThreads(this._repository);

  Stream<List<ChatThread>> call(String userId) {
    return _repository.watchThreads(userId);
  }
}
