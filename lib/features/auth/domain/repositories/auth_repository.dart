import '../../../shared/domain/models/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  AppUser? currentUser();
  Future<AppUser> signIn({required String email, required String password});
  Future<AppUser> signInWithGoogle();
  Future<AppUser> register({
    required String email,
    required String password,
    String? displayName,
  });
  Future<void> signOut();
  Future<void> sendPasswordReset({required String email});
}
