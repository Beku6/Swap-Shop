import '../repositories/settings_repository.dart';
import '../services/push_permission_handler.dart';

class TogglePushNotifications {
  const TogglePushNotifications({
    required SettingsRepository repository,
    required PushPermissionHandler permissionHandler,
  }) : _repository = repository,
       _permissionHandler = permissionHandler;

  final SettingsRepository _repository;
  final PushPermissionHandler _permissionHandler;

  Future<bool> call(bool enabled) async {
    if (!enabled) {
      await _repository.setPushEnabled(false);
      await _permissionHandler.setPushEnabled(false);
      await _permissionHandler.syncCurrentToken();
      return false;
    }

    final granted = await _permissionHandler.requestPermissionIfNeeded();
    if (!granted) {
      await _repository.setPushEnabled(false);
      await _permissionHandler.setPushEnabled(false);
      return false;
    }

    await _repository.setPushEnabled(true);
    await _permissionHandler.setPushEnabled(true);
    await _permissionHandler.syncCurrentToken();
    return true;
  }
}
