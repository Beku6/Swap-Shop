import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/auth/domain/usecases/register.dart';
import 'package:swap/features/auth/domain/usecases/send_password_reset.dart';
import 'package:swap/features/auth/domain/usecases/sign_in.dart';
import 'package:swap/features/auth/domain/usecases/sign_out.dart';

import '../../../helpers/fake_auth_repository.dart';

void main() {
  test('sign in calls repository', () async {
    final repo = FakeAuthRepository();
    final usecase = SignIn(repo);
    await usecase.call(email: 'test@example.com', password: 'password');
    expect(repo.currentUser()?.email, 'test@example.com');
  });

  test('register calls repository', () async {
    final repo = FakeAuthRepository();
    final usecase = Register(repo);
    await usecase.call(email: 'new@example.com', password: 'password', displayName: 'New');
    expect(repo.currentUser()?.email, 'new@example.com');
  });

  test('sign out clears user', () async {
    final repo = FakeAuthRepository();
    await repo.signIn(email: 'test@example.com', password: 'password');
    final usecase = SignOut(repo);
    await usecase.call();
    expect(repo.currentUser(), isNull);
  });

  test('password reset completes', () async {
    final repo = FakeAuthRepository();
    final usecase = SendPasswordReset(repo);
    await usecase.call(email: 'test@example.com');
    expect(true, isTrue);
  });
}
