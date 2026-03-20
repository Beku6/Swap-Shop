import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PublishJobStatus { idle, preparing, uploading, saving, success, error }

class PublishJobState {
  const PublishJobState({
    this.status = PublishJobStatus.idle,
    this.progress = 0,
    this.message = '',
    this.error,
    this.canRetry = false,
    this.listingTitle = '',
    this.thumbnailPath,
    this.hidden = false,
    this.updatedAt,
    this.stageStartedAt,
  });

  final PublishJobStatus status;
  final double progress;
  final String message;
  final String? error;
  final bool canRetry;
  final String listingTitle;
  final String? thumbnailPath;
  final bool hidden;
  final DateTime? updatedAt;
  final DateTime? stageStartedAt;

  int get percentInt => (progress.clamp(0.0, 1.0) * 100).round();

  bool get isActive =>
      status == PublishJobStatus.preparing ||
      status == PublishJobStatus.uploading ||
      status == PublishJobStatus.saving;

  bool get isVisible => status != PublishJobStatus.idle;
  bool get shouldShowBanner =>
      status != PublishJobStatus.idle &&
      !(hidden &&
          (status == PublishJobStatus.preparing ||
              status == PublishJobStatus.uploading ||
              status == PublishJobStatus.saving));

  PublishJobState copyWith({
    PublishJobStatus? status,
    double? progress,
    String? message,
    String? error,
    bool clearError = false,
    bool? canRetry,
    String? listingTitle,
    String? thumbnailPath,
    bool clearThumbnail = false,
    bool? hidden,
    DateTime? updatedAt,
    DateTime? stageStartedAt,
  }) {
    return PublishJobState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      message: message ?? this.message,
      error: clearError ? null : (error ?? this.error),
      canRetry: canRetry ?? this.canRetry,
      listingTitle: listingTitle ?? this.listingTitle,
      thumbnailPath: clearThumbnail
          ? null
          : (thumbnailPath ?? this.thumbnailPath),
      hidden: hidden ?? this.hidden,
      updatedAt: updatedAt ?? this.updatedAt,
      stageStartedAt: stageStartedAt ?? this.stageStartedAt,
    );
  }
}

final publishJobProvider =
    StateNotifierProvider<PublishJobController, PublishJobState>(
      (ref) => PublishJobController(),
    );

class PublishJobController extends StateNotifier<PublishJobState> {
  PublishJobController() : super(const PublishJobState());
  Timer? _dismissTimer;
  Timer? _watchdogTimer;
  Future<void> Function()? _retryAction;
  static const Duration _preparingTimeout = Duration(seconds: 90);
  static const Duration _savingTimeout = Duration(seconds: 90);
  static const Duration _uploadNoProgressTimeout = Duration(minutes: 2);
  static const Duration _activeStaleThreshold = Duration(minutes: 5);

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _watchdogTimer?.cancel();
    super.dispose();
  }

  void startPreparing({Future<void> Function()? retryAction}) {
    startPreparingForListing(
      listingTitle: state.listingTitle,
      thumbnailPath: state.thumbnailPath,
      retryAction: retryAction,
    );
  }

  void startPreparingForListing({
    required String listingTitle,
    String? thumbnailPath,
    Future<void> Function()? retryAction,
  }) {
    _dismissTimer?.cancel();
    _retryAction = retryAction;
    state = PublishJobState(
      status: PublishJobStatus.preparing,
      progress: 0.05,
      message: 'Preparing images...',
      canRetry: retryAction != null,
      listingTitle: listingTitle,
      thumbnailPath: thumbnailPath,
      hidden: false,
      updatedAt: DateTime.now(),
      stageStartedAt: DateTime.now(),
    );
    _ensureWatchdog();
  }

  void setUploading({
    required double uploadProgress,
    required int totalImages,
  }) {
    final clampedUpload = uploadProgress.clamp(0.0, 1.0);
    final mappedProgress = 0.1 + (clampedUpload * 0.8);
    final uploadedCount = totalImages <= 0
        ? 0
        : ((clampedUpload * totalImages).ceil()).clamp(1, totalImages);

    state = PublishJobState(
      status: PublishJobStatus.uploading,
      progress: mappedProgress,
      message: 'Uploading images ($uploadedCount/$totalImages)...',
      canRetry: _retryAction != null,
      listingTitle: state.listingTitle,
      thumbnailPath: state.thumbnailPath,
      hidden: state.hidden,
      updatedAt: DateTime.now(),
      stageStartedAt: state.status == PublishJobStatus.uploading
          ? state.stageStartedAt ?? DateTime.now()
          : DateTime.now(),
    );
    _ensureWatchdog();
  }

  void setSaving() {
    state = state.copyWith(
      status: PublishJobStatus.saving,
      progress: state.progress < 0.98 ? 0.98 : state.progress,
      message: 'Saving listing...',
      clearError: true,
      hidden: state.hidden,
      updatedAt: DateTime.now(),
      stageStartedAt: DateTime.now(),
    );
    _ensureWatchdog();
  }

  void setSuccess() {
    _dismissTimer?.cancel();
    _watchdogTimer?.cancel();
    state = PublishJobState(
      status: PublishJobStatus.success,
      progress: 1,
      message: 'Published',
      canRetry: false,
      listingTitle: state.listingTitle,
      thumbnailPath: state.thumbnailPath,
      hidden: false,
      updatedAt: DateTime.now(),
      stageStartedAt: DateTime.now(),
    );
    _dismissTimer = Timer(const Duration(milliseconds: 1200), reset);
  }

  void setError(String message, {Future<void> Function()? retryAction}) {
    _dismissTimer?.cancel();
    _watchdogTimer?.cancel();
    _retryAction = retryAction ?? _retryAction;
    state = PublishJobState(
      status: PublishJobStatus.error,
      progress: state.progress.clamp(0.0, 1.0),
      message: 'Upload failed',
      error: message,
      canRetry: _retryAction != null,
      listingTitle: state.listingTitle,
      thumbnailPath: state.thumbnailPath,
      hidden: false,
      updatedAt: DateTime.now(),
      stageStartedAt: DateTime.now(),
    );
  }

  Future<void> retry() async {
    final action = _retryAction;
    if (state.isActive || action == null) {
      return;
    }
    startPreparing(retryAction: action);
    await action();
  }

  void reset() {
    _dismissTimer?.cancel();
    _watchdogTimer?.cancel();
    _retryAction = null;
    state = const PublishJobState();
  }

  void hideBanner() {
    if (!state.isVisible) {
      return;
    }
    state = state.copyWith(hidden: true);
  }

  void onAppResumed() {
    if (!state.isActive) {
      return;
    }
    final lastUpdate = state.updatedAt;
    if (lastUpdate == null) {
      return;
    }
    final elapsed = DateTime.now().difference(lastUpdate);
    if (elapsed > _activeStaleThreshold) {
      setError('Upload stalled after resume. Please retry.');
      return;
    }
    _ensureWatchdog();
  }

  void _ensureWatchdog() {
    _watchdogTimer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) => _runWatchdog(),
    );
  }

  void _runWatchdog() {
    if (!state.isActive) {
      _watchdogTimer?.cancel();
      _watchdogTimer = null;
      return;
    }
    final now = DateTime.now();
    final stageStart = state.stageStartedAt ?? now;
    final lastUpdate = state.updatedAt ?? now;
    final stageElapsed = now.difference(stageStart);
    final noProgressElapsed = now.difference(lastUpdate);

    final timedOut = switch (state.status) {
      PublishJobStatus.preparing => stageElapsed > _preparingTimeout,
      PublishJobStatus.uploading =>
        noProgressElapsed > _uploadNoProgressTimeout,
      PublishJobStatus.saving => stageElapsed > _savingTimeout,
      _ => false,
    };

    if (timedOut) {
      setError('Upload timed out. Please retry.');
    }
  }
}
