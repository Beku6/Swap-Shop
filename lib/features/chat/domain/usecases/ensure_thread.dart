import '../repositories/chat_repository.dart';

class EnsureThread {
  final ChatRepository _repository;

  const EnsureThread(this._repository);

  Future<String> call({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserAvatar,
  }) {
    return _repository.ensureThread(
      currentUserId: currentUserId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
    );
  }
}
