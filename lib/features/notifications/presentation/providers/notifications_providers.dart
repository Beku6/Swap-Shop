import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/push_notification_service.dart';
import '../../../shared/domain/models/app_notification.dart';
import '../../data/firebase_notification_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/create_notification.dart';
import '../../domain/usecases/mark_notification_read.dart';
import '../../domain/usecases/upsert_device_token.dart';
import '../../domain/usecases/watch_notifications.dart';

final notificationsFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final notificationsFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return FirebaseNotificationRepository(
    ref.watch(notificationsFirestoreProvider),
    ref.watch(notificationsFirebaseAuthProvider),
  );
});

final firebaseMessagingProvider = Provider<FirebaseMessaging>((ref) {
  return FirebaseMessaging.instance;
});

final localNotificationsPluginProvider =
    Provider<FlutterLocalNotificationsPlugin>((ref) {
      return FlutterLocalNotificationsPlugin();
    });

final watchNotificationsProvider = Provider<WatchNotifications>((ref) {
  return WatchNotifications(ref.watch(notificationRepositoryProvider));
});

final createNotificationProvider = Provider<CreateNotification>((ref) {
  return CreateNotification(ref.watch(notificationRepositoryProvider));
});

final markNotificationReadProvider = Provider<MarkNotificationRead>((ref) {
  return MarkNotificationRead(ref.watch(notificationRepositoryProvider));
});

final upsertDeviceTokenProvider = Provider<UpsertDeviceToken>((ref) {
  return UpsertDeviceToken(ref.watch(notificationRepositoryProvider));
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  return PushNotificationService(
    messaging: ref.watch(firebaseMessagingProvider),
    firestore: ref.watch(notificationsFirestoreProvider),
    localNotifications: ref.watch(localNotificationsPluginProvider),
    upsertDeviceToken: ref.watch(upsertDeviceTokenProvider),
  );
});

final notificationsProvider =
    StreamProvider.family<List<AppNotification>, String>((ref, userId) {
      final currentUserId = ref.watch(authControllerProvider).user?.id;
      if (currentUserId == null || currentUserId != userId) {
        return Stream.value(const <AppNotification>[]);
      }
      return ref.watch(watchNotificationsProvider).call(userId);
    });
