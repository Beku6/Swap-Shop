import '../../../shared/domain/models/message.dart';
import '../repositories/chat_repository.dart';

class WatchMessages {
  final ChatRepository _repository;

  const WatchMessages(this._repository);

  Stream<List<Message>> call(String threadId) {
    return _repository.watchMessages(threadId);
  }
}
