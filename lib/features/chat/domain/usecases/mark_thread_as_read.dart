import '../repositories/chat_repository.dart';

class MarkThreadAsRead {
  final ChatRepository _repository;

  const MarkThreadAsRead(this._repository);

  Future<void> call({required String userId, required String threadId}) {
    return _repository.markThreadAsRead(userId: userId, threadId: threadId);
  }
}
