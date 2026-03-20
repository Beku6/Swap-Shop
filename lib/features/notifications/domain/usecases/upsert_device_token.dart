import '../repositories/notification_repository.dart';

class UpsertDeviceToken {
  final NotificationRepository _repository;

  const UpsertDeviceToken(this._repository);

  Future<void> call({
    required String userId,
    required String token,
    required String platform,
  }) {
    return _repository.upsertDeviceToken(
      userId: userId,
      token: token,
      platform: platform,
    );
  }
}
