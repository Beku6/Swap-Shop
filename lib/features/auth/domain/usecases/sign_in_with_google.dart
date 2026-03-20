import '../../../shared/domain/models/app_user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repository;

  const SignInWithGoogle(this._repository);

  Future<AppUser> call() {
    return _repository.signInWithGoogle();
  }
}
