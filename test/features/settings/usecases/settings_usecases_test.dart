import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/settings/domain/usecases/change_password.dart';
import 'package:swap/features/settings/domain/usecases/delete_account.dart';
import 'package:swap/features/settings/domain/usecases/toggle_push_notifications.dart';
import 'package:swap/features/settings/domain/usecases/update_display_name.dart';

import '../../../helpers/fake_push_permission_handler.dart';
import '../../../helpers/fake_settings_repository.dart';

void main() {
  test('updateDisplayName delegates to repository', () async {
    final repository = FakeSettingsRepository();
    final usecase = UpdateDisplayName(repository);

    await usecase('Taylor');

    expect(repository.updatedDisplayName, 'Taylor');
  });

  test('changePassword delegates to repository', () async {
    final repository = FakeSettingsRepository();
    final usecase = ChangePassword(repository);

    await usecase(currentPassword: 'old-pass', newPassword: 'new-pass');

    expect(repository.changedPasswordCurrent, 'old-pass');
    expect(repository.changedPasswordNext, 'new-pass');
  });

  test('deleteAccount delegates with password', () async {
    final repository = FakeSettingsRepository();
    final usecase = DeleteAccount(repository);

    await usecase(currentPassword: 'secret');

    expect(repository.deleteCalled, true);
    expect(repository.deletedPassword, 'secret');
  });

  test('togglePushNotifications disables push without permission request', () async {
    final repository = FakeSettingsRepository();
    final handler = FakePushPermissionHandler(permissionGranted: true);
    final usecase = TogglePushNotifications(
      repository: repository,
      permissionHandler: handler,
    );

    final enabled = await usecase(false);

    expect(enabled, false);
    expect(handler.requestCalled, false);
    expect(repository.pushEnabledValue, false);
    expect(handler.pushEnabledCalls, <bool>[false]);
    expect(handler.syncCalls, 1);
  });

  test('togglePushNotifications enables push when permission is granted', () async {
    final repository = FakeSettingsRepository();
    final handler = FakePushPermissionHandler(permissionGranted: true);
    final usecase = TogglePushNotifications(
      repository: repository,
      permissionHandler: handler,
    );

    final enabled = await usecase(true);

    expect(enabled, true);
    expect(handler.requestCalled, true);
    expect(repository.pushEnabledValue, true);
    expect(handler.pushEnabledCalls, <bool>[true]);
    expect(handler.syncCalls, 1);
  });

  test('togglePushNotifications keeps push disabled when permission is denied', () async {
    final repository = FakeSettingsRepository();
    final handler = FakePushPermissionHandler(permissionGranted: false);
    final usecase = TogglePushNotifications(
      repository: repository,
      permissionHandler: handler,
    );

    final enabled = await usecase(true);

    expect(enabled, false);
    expect(handler.requestCalled, true);
    expect(repository.pushEnabledValue, false);
    expect(handler.pushEnabledCalls, <bool>[false]);
    expect(handler.syncCalls, 0);
  });
}
