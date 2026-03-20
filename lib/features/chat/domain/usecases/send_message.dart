import '../../../shared/domain/models/message.dart';
import '../repositories/chat_repository.dart';

class SendMessage {
  final ChatRepository _repository;

  const SendMessage(this._repository);

  Future<void> call(Message message) {
    return _repository.sendMessage(message);
  }
}
