abstract class PushPermissionHandler {
  Future<bool> isPermissionGranted();

  Future<bool> requestPermissionIfNeeded();

  Future<void> setPushEnabled(bool enabled);

  Future<void> syncCurrentToken();
}
