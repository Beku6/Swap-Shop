import '../repositories/settings_repository.dart';

class DeleteAccount {
  const DeleteAccount(this._repository);

  final SettingsRepository _repository;

  Future<void> call({String? currentPassword}) {
    return _repository.deleteAccount(currentPassword: currentPassword);
  }
}
