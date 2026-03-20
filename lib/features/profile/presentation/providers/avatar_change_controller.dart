import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AvatarChangeStatus { idle, picking, cropping, uploading, success, error }

class AvatarChangeState {
  const AvatarChangeState({
    this.status = AvatarChangeStatus.idle,
    this.errorMessage,
    this.avatarUrl,
  });

  final AvatarChangeStatus status;
  final String? errorMessage;
  final String? avatarUrl;

  bool get isBusy =>
      status == AvatarChangeStatus.picking ||
      status == AvatarChangeStatus.cropping ||
      status == AvatarChangeStatus.uploading;

  AvatarChangeState copyWith({
    AvatarChangeStatus? status,
    String? errorMessage,
    bool clearError = false,
    String? avatarUrl,
    bool clearAvatarUrl = false,
  }) {
    return AvatarChangeState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      avatarUrl: clearAvatarUrl ? null : (avatarUrl ?? this.avatarUrl),
    );
  }
}

final avatarChangeControllerProvider = StateNotifierProvider.autoDispose
    .family<AvatarChangeController, AvatarChangeState, String>((ref, userId) {
      return AvatarChangeController();
    });

class AvatarChangeController extends StateNotifier<AvatarChangeState> {
  AvatarChangeController() : super(const AvatarChangeState());

  void beginPick() {
    state = state.copyWith(
      status: AvatarChangeStatus.picking,
      clearError: true,
    );
  }

  void beginCrop() {
    state = state.copyWith(
      status: AvatarChangeStatus.cropping,
      clearError: true,
    );
  }

  void beginUpload() {
    state = state.copyWith(
      status: AvatarChangeStatus.uploading,
      clearError: true,
    );
  }

  void completeSuccess({required String avatarUrl}) {
    state = AvatarChangeState(
      status: AvatarChangeStatus.success,
      avatarUrl: avatarUrl,
    );
  }

  void fail(String message) {
    state = state.copyWith(
      status: AvatarChangeStatus.error,
      errorMessage: message,
    );
  }

  void reset() {
    state = const AvatarChangeState();
  }
}
