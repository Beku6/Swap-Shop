import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'google-sign-in-cancelled':
        return 'Google sign-in was cancelled.';
      case 'google-config-missing':
        return 'Google sign-in is not configured for this app build.';
      case 'google-sign-in-failed':
        return 'Unable to sign in with Google right now.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return error.message ?? 'Authentication failed. Please try again.';
    }
  }
  return 'Authentication failed. Please try again.';
}
