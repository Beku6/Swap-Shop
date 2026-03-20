import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/app_error_mapper.dart';
import '../utils/app_error_reporter.dart';
import 'app_delayed_loading.dart';
import 'app_error_state.dart';

class AppAsyncValueBuilder<T> extends StatelessWidget {
  const AppAsyncValueBuilder({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.onRetry,
    this.errorTitle = 'Something went wrong',
    this.enableReportIssue = true,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
    FutureOr<void> Function()? onRetry,
    Future<void> Function()? onReportIssue,
  )?
  errorBuilder;
  final FutureOr<void> Function()? onRetry;
  final String errorTitle;
  final bool enableReportIssue;

  @override
  Widget build(BuildContext context) {
    final content = value.when(
      loading: () => KeyedSubtree(
        key: const ValueKey<String>('loading'),
        child: AppDelayedLoading(
          child: loadingBuilder?.call(context) ?? const _DefaultLoading(),
        ),
      ),
      error: (error, stackTrace) {
        final mapped = AppErrorMapper.mapWithDetails(error);
        final report = enableReportIssue
            ? () => AppErrorReporter.report(
                error: error,
                stackTrace: stackTrace,
                reason: 'async_value_builder',
                context: <String, Object?>{
                  'message': mapped.message,
                  'details': mapped.debugDetails,
                },
              )
            : null;

        if (errorBuilder != null) {
          return KeyedSubtree(
            key: const ValueKey<String>('error'),
            child: errorBuilder!(
              context,
              error,
              stackTrace,
              onRetry,
              report,
            ),
          );
        }

        return KeyedSubtree(
          key: const ValueKey<String>('error'),
          child: AppErrorState(
            title: errorTitle,
            message: mapped.message,
            onRetry: onRetry,
            onReportIssue: report,
          ),
        );
      },
      data: (data) => KeyedSubtree(
        key: const ValueKey<String>('data'),
        child: dataBuilder(data),
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      reverseDuration: const Duration(milliseconds: 120),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeOutCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: content,
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
