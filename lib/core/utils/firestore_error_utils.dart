import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

String firestoreFriendlyMessage(Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'failed-precondition':
        final indexUrl = _extractIndexUrl(error.message);
        if (indexUrl != null) {
          return 'This query needs a Firestore index. Create it from the logged link and retry.';
        }
        return 'This query needs additional Firestore configuration. Please try again in a moment.';
      case 'permission-denied':
        return 'You do not have permission to view this data.';
      case 'unavailable':
        return 'Service is temporarily unavailable. Please retry.';
      default:
        return error.message ?? 'Unable to load data right now.';
    }
  }
  return 'Unable to load data right now.';
}

void logFirestoreQueryError({
  required String queryName,
  required Object error,
  StackTrace? stackTrace,
}) {
  if (error is! FirebaseException) {
    developer.log('Firestore[$queryName] unexpected error: $error');
    if (stackTrace != null) {
      developer.log('Firestore[$queryName] stackTrace: $stackTrace');
    }
    return;
  }

  developer.log(
    'Firestore[$queryName] failed with code=${error.code} message=${error.message}',
  );

  final indexUrl = _extractIndexUrl(error.message);
  if (error.code == 'failed-precondition' && indexUrl != null) {
    developer.log(
      'Firestore[$queryName] index required. Create it here: $indexUrl',
    );
  } else if (error.code == 'permission-denied') {
    developer.log(
      'Firestore[$queryName] permission denied. Check authenticated user uid and deployed Firestore rules.',
    );
  }

  if (stackTrace != null) {
    developer.log('Firestore[$queryName] stackTrace: $stackTrace');
  }
}

String? _extractIndexUrl(String? message) {
  if (message == null || message.isEmpty) {
    return null;
  }
  final match = RegExp(
    r'https://console\.firebase\.google\.com[^\s]+',
  ).firstMatch(message);
  return match?.group(0);
}
