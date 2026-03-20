import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../data/firebase_settings_repository.dart';
import '../../data/push_permission_handler_adapter.dart';
import '../../domain/models/settings_profile.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/push_permission_handler.dart';
import '../../domain/usecases/change_password.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/set_private_profile.dart';
import '../../domain/usecases/toggle_push_notifications.dart';
import '../../domain/usecases/update_display_name.dart';
import '../../domain/usecases/update_email.dart';
import '../../domain/usecases/watch_settings_profile.dart';

final settingsFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final settingsFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return FirebaseSettingsRepository(
    auth: ref.watch(settingsFirebaseAuthProvider),
    firestore: ref.watch(settingsFirestoreProvider),
  );
});

final pushPermissionHandlerProvider = Provider<PushPermissionHandler>((ref) {
  return PushPermissionHandlerAdapter(ref.watch(pushNotificationServiceProvider));
});

final watchSettingsProfileProvider = Provider<WatchSettingsProfile>((ref) {
  return WatchSettingsProfile(ref.watch(settingsRepositoryProvider));
});

final settingsProfileProvider =
    StreamProvider.family<SettingsProfile, String>((ref, userId) {
      return ref.watch(watchSettingsProfileProvider).call(userId);
    });

final updateDisplayNameProvider = Provider<UpdateDisplayName>((ref) {
  return UpdateDisplayName(ref.watch(settingsRepositoryProvider));
});

final updateEmailProvider = Provider<UpdateEmail>((ref) {
  return UpdateEmail(ref.watch(settingsRepositoryProvider));
});

final changePasswordProvider = Provider<ChangePassword>((ref) {
  return ChangePassword(ref.watch(settingsRepositoryProvider));
});

final setPrivateProfileProvider = Provider<SetPrivateProfile>((ref) {
  return SetPrivateProfile(ref.watch(settingsRepositoryProvider));
});

final deleteAccountProvider = Provider<DeleteAccount>((ref) {
  return DeleteAccount(ref.watch(settingsRepositoryProvider));
});

final togglePushNotificationsProvider = Provider<TogglePushNotifications>((ref) {
  return TogglePushNotifications(
    repository: ref.watch(settingsRepositoryProvider),
    permissionHandler: ref.watch(pushPermissionHandlerProvider),
  );
});

final pushPermissionGrantedProvider = FutureProvider<bool>((ref) async {
  return ref.watch(pushPermissionHandlerProvider).isPermissionGranted();
});

final profileOwnerIdProvider = Provider<String?>((ref) {
  return ref.watch(authControllerProvider).user?.id;
});
