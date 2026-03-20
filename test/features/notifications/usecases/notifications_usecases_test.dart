import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/notifications/domain/usecases/create_notification.dart';
import 'package:swap/features/notifications/domain/usecases/mark_notification_read.dart';
import 'package:swap/features/notifications/domain/usecases/upsert_device_token.dart';
import 'package:swap/features/notifications/domain/usecases/watch_notifications.dart';
import 'package:swap/features/shared/domain/models/app_notification.dart';

import '../../../helpers/fake_notification_repository.dart';

void main() {
  test('create notification stores item and watch returns it first', () async {
    final repo = FakeNotificationRepository();
    final createNotification = CreateNotification(repo);
    final watchNotifications = WatchNotifications(repo);

    await createNotification(
      AppNotification(
        id: '',
        userId: 'u1',
        type: 'message',
        title: 'New Message',
        body: 'hello',
        data: const <String, dynamic>{'threadId': 't1'},
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );

    final items = await watchNotifications('u1').first;
    expect(items.length, 1);
    expect(items.first.title, 'New Message');
  });

  test('mark read updates unread state', () async {
    final now = DateTime.now();
    final repo = FakeNotificationRepository(
      seed: <AppNotification>[
        AppNotification(
          id: 'n1',
          userId: 'u1',
          type: 'offer',
          title: 'Proposal',
          body: 'pending',
          createdAt: now,
          isRead: false,
        ),
      ],
    );

    await MarkNotificationRead(repo).call(userId: 'u1', notificationId: 'n1');

    final items = await WatchNotifications(repo).call('u1').first;
    expect(items.first.isRead, isTrue);
  });

  test('upsert device token stores user token by platform', () async {
    final repo = FakeNotificationRepository();

    await UpsertDeviceToken(
      repo,
    ).call(userId: 'u1', token: 'token-123', platform: 'android');

    expect(repo.hasDeviceToken('u1', 'android', 'token-123'), isTrue);
  });
}
