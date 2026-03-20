import '../repositories/auth_repository.dart';

class SendPasswordReset {
  final AuthRepository _repository;

  const SendPasswordReset(this._repository);

  Future<void> call({required String email}) {
    return _repository.sendPasswordReset(email: email);
  }
}
