import '../repositories/settings_repository.dart';

class ChangePassword {
  const ChangePassword(this._repository);

  final SettingsRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
