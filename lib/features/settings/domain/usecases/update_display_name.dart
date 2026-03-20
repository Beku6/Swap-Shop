import '../repositories/settings_repository.dart';

class UpdateDisplayName {
  const UpdateDisplayName(this._repository);

  final SettingsRepository _repository;

  Future<void> call(String displayName) {
    return _repository.updateDisplayName(displayName);
  }
}
