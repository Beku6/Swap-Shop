import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppMappedError {
  const AppMappedError({
    required this.message,
    this.debugDetails,
  });

  final String message;
  final String? debugDetails;
}

class AppErrorMapper {
  static AppMappedError mapWithDetails(Object error) {
    if (error is FirebaseAuthException) {
      return _mapFirebaseAuth(error);
    }

    if (error is FirebaseException) {
      return _mapFirebase(error);
    }

    if (error is PlatformException) {
      return _mapPlatform(error);
    }

    if (error is SocketException) {
      return const AppMappedError(
        message: 'No internet connection. Please try again when online.',
      );
    }

    if (error is TimeoutException) {
      return const AppMappedError(
        message: 'Request timed out. Please try again.',
      );
    }

    if (error is StorageException) {
      return _mapSupabaseStorage(error);
    }

    if (error is AuthException) {
      return AppMappedError(
        message: error.message,
        debugDetails: 'SupabaseAuthException(${error.statusCode})',
      );
    }

    if (error is PostgrestException) {
      return AppMappedError(
        message: 'Service is unavailable right now. Please retry shortly.',
        debugDetails: 'SupabasePostgrestException(${error.code}): ${error.message}',
      );
    }

    return AppMappedError(
      message: 'Something went wrong. Please try again.',
      debugDetails: error.toString(),
    );
  }

  static String map(Object error) {
    return mapWithDetails(error).message;
  }

  static AppMappedError _mapFirebaseAuth(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return const AppMappedError(
          message: 'Please enter a valid email address.',
        );
      case 'user-not-found':
        return const AppMappedError(
          message: 'No account found with this email.',
        );
      case 'wrong-password':
      case 'invalid-credential':
        return const AppMappedError(
          message: 'Your password is incorrect.',
        );
      case 'email-already-in-use':
        return const AppMappedError(
          message: 'This email is already in use.',
        );
      case 'weak-password':
        return const AppMappedError(
          message: 'New password is too weak.',
        );
      case 'requires-recent-login':
        return const AppMappedError(
          message: 'Please re-login to continue this action.',
        );
      case 'network-request-failed':
        return const AppMappedError(
          message: 'Network error. Please check your connection and retry.',
        );
      case 'too-many-requests':
        return const AppMappedError(
          message: 'Too many attempts. Please try again later.',
        );
      default:
        return AppMappedError(
          message: error.message ?? 'Authentication failed. Please try again.',
          debugDetails: 'FirebaseAuthException(${error.code})',
        );
    }
  }

  static AppMappedError _mapFirebase(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return const AppMappedError(
          message: 'You do not have permission for this action.',
        );
      case 'failed-precondition':
        return const AppMappedError(
          message: 'This query needs additional Firestore setup. Please retry in a moment.',
        );
      case 'unavailable':
        return const AppMappedError(
          message: 'Service is temporarily unavailable. Please retry.',
        );
      case 'not-found':
        return const AppMappedError(
          message: 'Requested data could not be found.',
        );
      case 'deadline-exceeded':
        return const AppMappedError(
          message: 'Request timed out. Please try again.',
        );
      default:
        return AppMappedError(
          message: error.message ?? 'Action failed. Please try again.',
          debugDetails: 'FirebaseException(${error.code})',
        );
    }
  }

  static AppMappedError _mapPlatform(PlatformException error) {
    switch (error.code) {
      case 'network_error':
        return const AppMappedError(
          message: 'Network error. Please check your connection.',
        );
      case 'sign_in_failed':
        return const AppMappedError(
          message: 'Unable to complete sign in. Please retry.',
        );
      default:
        return AppMappedError(
          message: error.message ?? 'Something went wrong. Please try again.',
          debugDetails: 'PlatformException(${error.code})',
        );
    }
  }

  static AppMappedError _mapSupabaseStorage(StorageException error) {
    final statusCode = error.statusCode?.toString();
    final message = error.message.toLowerCase();

    final bucketMissing = statusCode == '404' ||
        message.contains('bucket not found') ||
        (message.contains('bucket') && message.contains('not found'));
    if (bucketMissing) {
      return const AppMappedError(
        message: 'Storage bucket not found. Please contact support.',
        debugDetails: 'SupabaseStorage(bucket_not_found)',
      );
    }

    final policyDenied = statusCode == '401' ||
        statusCode == '403' ||
        message.contains('policy') ||
        message.contains('forbidden') ||
        message.contains('permission denied');
    if (policyDenied) {
      return const AppMappedError(
        message: 'Storage permission denied. Please contact support.',
        debugDetails: 'SupabaseStorage(policy_denied)',
      );
    }

    return AppMappedError(
      message: 'Storage request failed. Please try again.',
      debugDetails: 'SupabaseStorage(${error.statusCode}) ${error.message}',
    );
  }
}
