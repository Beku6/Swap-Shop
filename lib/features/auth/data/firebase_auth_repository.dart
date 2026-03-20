import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/observability/app_analytics.dart';
import '../../shared/domain/models/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final AppAnalytics _analytics;

  FirebaseAuthRepository(this._auth, this._googleSignIn, this._analytics);

  @override
  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_mapUser);
  }

  @override
  AppUser? currentUser() {
    return _mapUser(_auth.currentUser);
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = _mapUser(credential.user);
    if (user == null) {
      throw StateError('Sign in failed.');
    }
    await _analytics.logSignIn(method: 'password');
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in cancelled.',
        );
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;
      if (idToken == null || accessToken == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Google sign-in token not received.',
        );
      }

      final credential = GoogleAuthProvider.credential(
        accessToken: accessToken,
        idToken: idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = _mapUser(userCredential.user);
      if (user == null) {
        throw FirebaseAuthException(
          code: 'google-sign-in-failed',
          message: 'Google sign-in did not return a valid user.',
        );
      }
      await _analytics.logSignIn(method: 'google');
      return user;
    } on FirebaseAuthException catch (error, stackTrace) {
      _logGoogleSignInFailure(
        source: 'firebase_auth',
        code: error.code,
        message: error.message,
        details: error.toString(),
        stackTrace: stackTrace,
      );
      rethrow;
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();
      final message = (error.message ?? '').toLowerCase();
      final isShaMissing =
          message.contains('developer_error') ||
          message.contains('10') ||
          message.contains('sha');
      _logGoogleSignInFailure(
        source: 'platform',
        code: error.code,
        message: error.message,
        details: error.details?.toString(),
      );
      if (isShaMissing) {
        // Developer-facing hint for missing SHA-1 / OAuth setup.
        developer.log(
          'Google Sign-In config hint: check Android package name, google-services.json at android/app/, and SHA-1/SHA-256 for current keystore.',
        );
        throw FirebaseAuthException(
          code: 'google-config-missing',
          message: 'Google sign-in is not configured for this app build.',
        );
      }
      if (code == 'sign_in_canceled' || code == 'sign_in_cancelled') {
        throw FirebaseAuthException(
          code: 'google-sign-in-cancelled',
          message: 'Google sign-in cancelled.',
        );
      }
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: error.message ?? 'Google sign-in failed.',
      );
    } catch (error, stackTrace) {
      _logGoogleSignInFailure(
        source: 'unknown',
        code: 'unknown',
        message: error.toString(),
        details: error.runtimeType.toString(),
        stackTrace: stackTrace,
      );
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Unable to sign in with Google at the moment.',
      );
    }
  }

  void _logGoogleSignInFailure({
    required String source,
    required String code,
    String? message,
    String? details,
    StackTrace? stackTrace,
  }) {
    developer.log(
      'Google Sign-In failed [$source] code=$code message=${message ?? 'n/a'} details=${details ?? 'n/a'}',
    );
    if (stackTrace != null) {
      developer.log('Google Sign-In stackTrace: $stackTrace');
    }
  }

  @override
  Future<AppUser> register({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Registration failed.');
    }
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
    }
    await _analytics.logSignUp(method: 'password');
    return _mapUser(user) ??
        AppUser(
          id: user.uid,
          email: user.email ?? email,
          displayName: displayName,
        );
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  AppUser? _mapUser(User? user) {
    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }
}
