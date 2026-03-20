import 'package:swap/features/settings/domain/models/settings_profile.dart';
import 'package:swap/features/settings/domain/repositories/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({
    SettingsProfile? profile,
  }) : _profile =
           profile ??
           const SettingsProfile(
             userId: 'u1',
             email: 'user@example.com',
             displayName: 'User',
             pushEnabled: false,
             isPrivate: false,
           );

  final SettingsProfile _profile;

  String? updatedDisplayName;
  String? updatedEmail;
  String? updatedEmailPassword;
  String? changedPasswordCurrent;
  String? changedPasswordNext;
  bool? pushEnabledValue;
  bool? privateValue;
  String? deletedPassword;
  bool deleteCalled = false;

  @override
  Stream<SettingsProfile> watchProfile(String userId) async* {
    yield _profile;
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    updatedDisplayName = displayName;
  }

  @override
  Future<void> updateEmail({
    required String email,
    String? currentPassword,
  }) async {
    updatedEmail = email;
    updatedEmailPassword = currentPassword;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    changedPasswordCurrent = currentPassword;
    changedPasswordNext = newPassword;
  }

  @override
  Future<void> setPushEnabled(bool enabled) async {
    pushEnabledValue = enabled;
  }

  @override
  Future<void> setPrivateProfile(bool isPrivate) async {
    privateValue = isPrivate;
  }

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    deletedPassword = currentPassword;
    deleteCalled = true;
  }
}
