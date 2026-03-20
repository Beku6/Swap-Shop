import 'package:swap/features/settings/domain/services/push_permission_handler.dart';

class FakePushPermissionHandler implements PushPermissionHandler {
  FakePushPermissionHandler({this.permissionGranted = false});

  bool permissionGranted;
  bool requestCalled = false;
  final List<bool> pushEnabledCalls = <bool>[];
  int syncCalls = 0;

  @override
  Future<bool> isPermissionGranted() async {
    return permissionGranted;
  }

  @override
  Future<bool> requestPermissionIfNeeded() async {
    requestCalled = true;
    return permissionGranted;
  }

  @override
  Future<void> setPushEnabled(bool enabled) async {
    pushEnabledCalls.add(enabled);
  }

  @override
  Future<void> syncCurrentToken() async {
    syncCalls += 1;
  }
}
