import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AppErrorReporter {
  const AppErrorReporter._();

  static Future<void> report({
    required Object error,
    required StackTrace stackTrace,
    String reason = 'handled_error',
    Map<String, Object?> context = const <String, Object?>{},
    bool fatal = false,
  }) async {
    developer.log(
      '[$reason] ${error.runtimeType}: $error',
      stackTrace: stackTrace,
      name: 'AppErrorReporter',
    );

    try {
      final crashlytics = FirebaseCrashlytics.instance;
      await crashlytics.setCustomKey('error_reason', reason);
      for (final entry in context.entries) {
        await crashlytics.setCustomKey(
          'ctx_${entry.key}',
          entry.value?.toString() ?? 'null',
        );
      }
      await crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (_) {
      // Best effort: never fail UI flows due to logging.
    }
  }
}
