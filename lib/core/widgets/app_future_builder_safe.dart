import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_error_mapper.dart';
import '../utils/app_error_reporter.dart';
import 'app_delayed_loading.dart';
import 'app_error_state.dart';

class AppFutureBuilderSafe<T> extends StatefulWidget {
  const AppFutureBuilderSafe({
    super.key,
    required this.futureFactory,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorTitle = 'Unable to load',
    this.enableReportIssue = true,
  });

  final Future<T> Function() futureFactory;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final String errorTitle;
  final bool enableReportIssue;

  @override
  State<AppFutureBuilderSafe<T>> createState() => _AppFutureBuilderSafeState<T>();
}

class _AppFutureBuilderSafeState<T> extends State<AppFutureBuilderSafe<T>> {
  late Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.futureFactory();
  }

  @override
  void didUpdateWidget(covariant AppFutureBuilderSafe<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.futureFactory != widget.futureFactory) {
      _future = widget.futureFactory();
    }
  }

  void _retry() {
    setState(() {
      _future = widget.futureFactory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          final mapped = AppErrorMapper.mapWithDetails(error);
          final report = widget.enableReportIssue
              ? () => AppErrorReporter.report(
                  error: error,
                  stackTrace: snapshot.stackTrace ?? StackTrace.current,
                  reason: 'future_builder_safe',
                  context: <String, Object?>{
                    'message': mapped.message,
                    'details': mapped.debugDetails,
                  },
                )
              : null;
          return KeyedSubtree(
            key: const ValueKey<String>('error'),
            child: AppErrorState(
              title: widget.errorTitle,
              message: mapped.message,
              onRetry: _retry,
              onReportIssue: report,
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return KeyedSubtree(
            key: const ValueKey<String>('loading'),
            child: AppDelayedLoading(
              child:
                  widget.loadingBuilder?.call(context) ??
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!snapshot.hasData) {
          if (null is T) {
            return KeyedSubtree(
              key: const ValueKey<String>('data'),
              child: widget.dataBuilder(context, null as T),
            );
          }
          return KeyedSubtree(
            key: const ValueKey<String>('loading'),
            child: AppDelayedLoading(
              child:
                  widget.loadingBuilder?.call(context) ??
                  const Center(child: CircularProgressIndicator()),
            ),
          );
        }

        return KeyedSubtree(
          key: const ValueKey<String>('data'),
          child: widget.dataBuilder(context, snapshot.data as T),
        );
      },
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
