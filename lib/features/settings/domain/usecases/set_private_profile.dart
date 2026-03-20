import '../repositories/settings_repository.dart';

class SetPrivateProfile {
  const SetPrivateProfile(this._repository);

  final SettingsRepository _repository;

  Future<void> call(bool isPrivate) {
    return _repository.setPrivateProfile(isPrivate);
  }
}
