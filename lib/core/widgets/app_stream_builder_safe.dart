import 'dart:async';

import 'package:flutter/material.dart';

import '../utils/app_error_mapper.dart';
import '../utils/app_error_reporter.dart';
import 'app_delayed_loading.dart';
import 'app_error_state.dart';

class AppStreamBuilderSafe<T> extends StatefulWidget {
  const AppStreamBuilderSafe({
    super.key,
    required this.streamFactory,
    required this.dataBuilder,
    this.loadingBuilder,
    this.errorTitle = 'Unable to load',
    this.enableReportIssue = true,
  });

  final Stream<T> Function() streamFactory;
  final Widget Function(BuildContext context, T data) dataBuilder;
  final WidgetBuilder? loadingBuilder;
  final String errorTitle;
  final bool enableReportIssue;

  @override
  State<AppStreamBuilderSafe<T>> createState() => _AppStreamBuilderSafeState<T>();
}

class _AppStreamBuilderSafeState<T> extends State<AppStreamBuilderSafe<T>> {
  late Stream<T> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.streamFactory();
  }

  @override
  void didUpdateWidget(covariant AppStreamBuilderSafe<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamFactory != widget.streamFactory) {
      _stream = widget.streamFactory();
    }
  }

  void _retry() {
    setState(() {
      _stream = widget.streamFactory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = StreamBuilder<T>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          final mapped = AppErrorMapper.mapWithDetails(error);
          final report = widget.enableReportIssue
              ? () => AppErrorReporter.report(
                  error: error,
                  stackTrace: snapshot.stackTrace ?? StackTrace.current,
                  reason: 'stream_builder_safe',
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

        if (snapshot.connectionState == ConnectionState.waiting ||
            !snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.active &&
              !snapshot.hasData &&
              null is T) {
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
