import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository _repository;

  const Register(this._repository);

  Future<void> call({required String email, required String password, String? displayName}) {
    return _repository.register(email: email, password: password, displayName: displayName);
  }
}
