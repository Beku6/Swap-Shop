import '../repositories/settings_repository.dart';

class UpdateEmail {
  const UpdateEmail(this._repository);

  final SettingsRepository _repository;

  Future<void> call({
    required String email,
    String? currentPassword,
  }) {
    return _repository.updateEmail(
      email: email,
      currentPassword: currentPassword,
    );
  }
}
