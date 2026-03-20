import '../models/settings_profile.dart';

abstract class SettingsRepository {
  Stream<SettingsProfile> watchProfile(String userId);

  Future<void> updateDisplayName(String displayName);

  Future<void> updateEmail({
    required String email,
    String? currentPassword,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> setPushEnabled(bool enabled);

  Future<void> setPrivateProfile(bool isPrivate);

  Future<void> deleteAccount({String? currentPassword});
}
