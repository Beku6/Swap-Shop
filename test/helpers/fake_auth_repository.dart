import 'package:swap/features/auth/domain/repositories/auth_repository.dart';
import 'package:swap/features/shared/domain/models/app_user.dart';

class FakeAuthRepository implements AuthRepository {
  AppUser? _user;

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _user;
  }

  @override
  AppUser? currentUser() => _user;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    _user = AppUser(id: '1', email: email);
    return _user!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    _user = const AppUser(id: 'google-1', email: 'google@example.com');
    return _user!;
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _user = AppUser(id: '1', email: email, displayName: displayName);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<void> sendPasswordReset({required String email}) async {}
}
