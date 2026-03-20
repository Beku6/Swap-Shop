import '../models/settings_profile.dart';
import '../repositories/settings_repository.dart';

class WatchSettingsProfile {
  const WatchSettingsProfile(this._repository);

  final SettingsRepository _repository;

  Stream<SettingsProfile> call(String userId) {
    return _repository.watchProfile(userId);
  }
}
