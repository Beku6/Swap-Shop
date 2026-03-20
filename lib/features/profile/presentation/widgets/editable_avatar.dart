import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_error_mapper.dart';
import '../providers/avatar_change_controller.dart';
import '../providers/profile_providers.dart';

class EditableAvatar extends ConsumerStatefulWidget {
  const EditableAvatar({
    super.key,
    required this.userId,
    required this.avatarUrl,
    required this.fallbackUrl,
    required this.canEdit,
    this.size = 88,
  });

  final String userId;
  final String? avatarUrl;
  final String? fallbackUrl;
  final bool canEdit;
  final double size;

  @override
  ConsumerState<EditableAvatar> createState() => _EditableAvatarState();
}

class _EditableAvatarState extends ConsumerState<EditableAvatar> {
  bool _isRemoved = false;
  String? _localAvatarUrl;
  final ImagePicker _picker = ImagePicker();
  int _operationId = 0;

  String? get _displayUrl {
    if (_isRemoved) {
      return widget.fallbackUrl;
    }
    final customUrl = _localAvatarUrl ?? widget.avatarUrl;
    if (customUrl != null && customUrl.isNotEmpty) {
      return customUrl;
    }
    return widget.fallbackUrl;
  }

  bool get _hasCustomAvatar {
    final customUrl = _localAvatarUrl ?? widget.avatarUrl;
    return !_isRemoved && customUrl != null && customUrl.isNotEmpty;
  }

  Future<void> _openActions() async {
    final changeState = ref.read(avatarChangeControllerProvider(widget.userId));
    if (!widget.canEdit || changeState.isBusy) {
      return;
    }

    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.appBorder(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.of(context).pop(_AvatarAction.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Take photo'),
                onTap: () => Navigator.of(context).pop(_AvatarAction.camera),
              ),
              if (_hasCustomAvatar)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Remove photo'),
                  onTap: () => Navigator.of(context).pop(_AvatarAction.remove),
                ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    if (action == _AvatarAction.gallery) {
      await _pickAndUploadAvatar(ImageSource.gallery);
      return;
    }
    if (action == _AvatarAction.camera) {
      await _pickAndUploadAvatar(ImageSource.camera);
      return;
    }
    if (action == _AvatarAction.remove) {
      await _removeAvatar();
    }
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final changeController = ref.read(
      avatarChangeControllerProvider(widget.userId).notifier,
    );
    final changeState = ref.read(avatarChangeControllerProvider(widget.userId));
    if (!widget.canEdit || changeState.isBusy) {
      return;
    }
    final currentOperation = ++_operationId;
    changeController.beginPick();

    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: source,
        imageQuality: 100,
        maxWidth: 4096,
        maxHeight: 4096,
      );
    } on PlatformException catch (error) {
      if (!_isOperationActive(currentOperation)) {
        return;
      }
      final message = _imagePickerErrorMessage(error);
      changeController.fail(message);
      _showMessage(message);
      return;
    }
    if (!_isOperationActive(currentOperation)) {
      return;
    }
    if (picked == null) {
      changeController.reset();
      return;
    }

    changeController.beginCrop();
    CroppedFile? cropped;
    try {
      cropped = await ImageCropper().cropImage(
        sourcePath: picked.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 96,
        maxWidth: 2048,
        maxHeight: 2048,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust avatar',
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: CropStyle.circle,
            initAspectRatio: CropAspectRatioPreset.square,
          ),
          IOSUiSettings(
            title: 'Adjust avatar',
            aspectRatioLockEnabled: true,
            rotateButtonsHidden: true,
            rotateClockwiseButtonHidden: true,
            resetAspectRatioEnabled: false,
            cropStyle: CropStyle.circle,
          ),
        ],
      );
    } on PlatformException catch (error) {
      if (!_isOperationActive(currentOperation)) {
        return;
      }
      final message = _cropperErrorMessage(error);
      changeController.fail(message);
      _showMessage(message);
      return;
    }
    if (!_isOperationActive(currentOperation)) {
      return;
    }
    if (cropped == null) {
      changeController.reset();
      return;
    }

    await _uploadAvatarFile(
      operationId: currentOperation,
      file: File(cropped.path),
      fromRetry: false,
    );
  }

  Future<void> _uploadAvatarFile({
    required int operationId,
    required File file,
    required bool fromRetry,
  }) async {
    final changeController = ref.read(
      avatarChangeControllerProvider(widget.userId).notifier,
    );
    changeController.beginUpload();

    try {
      final url = await ref
          .read(profileAvatarServiceProvider)
          .uploadAvatar(userId: widget.userId, file: file);
      if (!_isOperationActive(operationId)) {
        return;
      }
      setState(() {
        _localAvatarUrl = url;
        _isRemoved = false;
      });
      changeController.completeSuccess(avatarUrl: url);
    } on AvatarValidationException catch (error) {
      if (!_isOperationActive(operationId)) {
        return;
      }
      changeController.fail(error.message);
      _showMessage(error.message);
    } on StorageException catch (error) {
      if (!_isOperationActive(operationId)) {
        return;
      }
      final message = _avatarStorageErrorMessage(error);
      changeController.fail(message);
      _showMessage(
        message,
        retryAction: fromRetry ? null : () => _retryUploadWithFile(file.path),
      );
    } catch (error) {
      if (!_isOperationActive(operationId)) {
        return;
      }
      final message = AppErrorMapper.map(error);
      changeController.fail(message);
      _showMessage(
        message,
        retryAction: fromRetry ? null : () => _retryUploadWithFile(file.path),
      );
    }
  }

  Future<void> _removeAvatar() async {
    final changeController = ref.read(
      avatarChangeControllerProvider(widget.userId).notifier,
    );
    final changeState = ref.read(avatarChangeControllerProvider(widget.userId));
    if (changeState.isBusy) {
      return;
    }
    final currentOperation = ++_operationId;
    changeController.beginUpload();

    try {
      await ref
          .read(profileAvatarServiceProvider)
          .removeAvatar(userId: widget.userId);
      if (!_isOperationActive(currentOperation)) {
        return;
      }
      setState(() {
        _localAvatarUrl = null;
        _isRemoved = true;
      });
      changeController.completeSuccess(avatarUrl: '');
    } catch (error) {
      if (!_isOperationActive(currentOperation)) {
        return;
      }
      final message = AppErrorMapper.map(error);
      changeController.fail(message);
      _showMessage(message, retryAction: _removeAvatar);
    }
  }

  void _retryUploadWithFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      _showMessage('Retry failed. Please choose the photo again.');
      return;
    }
    final retryOperation = ++_operationId;
    _uploadAvatarFile(operationId: retryOperation, file: file, fromRetry: true);
  }

  String _avatarStorageErrorMessage(StorageException error) {
    final status = (error.statusCode ?? '').toString();
    final message = error.message.toLowerCase();
    final bucketMissing =
        status == '404' ||
        message.contains('bucket not found') ||
        (message.contains('bucket') && message.contains('not found'));
    if (bucketMissing) {
      return 'Supabase bucket not found: avatars.';
    }

    final policyDenied =
        status == '401' ||
        status == '403' ||
        message.contains('policy') ||
        message.contains('forbidden') ||
        message.contains('permission denied');
    if (policyDenied) {
      return 'Supabase Storage policy denied avatar upload.';
    }

    return 'Avatar upload failed. Please check Supabase configuration.';
  }

  String _imagePickerErrorMessage(PlatformException error) {
    switch (error.code) {
      case 'camera_access_denied':
      case 'camera_access_denied_without_prompt':
      case 'camera_access_restricted':
        return 'Camera permission is required to take a profile photo.';
      case 'photo_access_denied':
      case 'photo_access_denied_without_prompt':
      case 'photo_access_restricted':
        return 'Photo library permission is required to choose an avatar.';
      case 'no_available_camera':
        return 'No camera available on this device.';
      default:
        return AppErrorMapper.map(error);
    }
  }

  String _cropperErrorMessage(PlatformException error) {
    if (error.code == 'crop_error') {
      return 'Could not crop this image. Please try another photo.';
    }
    return AppErrorMapper.map(error);
  }

  bool _isOperationActive(int operationId) {
    return mounted && operationId == _operationId;
  }

  void _showMessage(String message, {VoidCallback? retryAction}) {
    if (!mounted) {
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        action: retryAction == null
            ? null
            : SnackBarAction(label: 'Retry', onPressed: retryAction),
      ),
    );
  }

  @override
  void dispose() {
    _operationId++;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final changeState = ref.watch(
      avatarChangeControllerProvider(widget.userId),
    );
    final isUploading = changeState.isBusy;
    final appBorder = AppColors.appBorder(context);
    final appBg = AppColors.appBackground(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return GestureDetector(
      onTap: widget.canEdit && !isUploading ? _openActions : null,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: widget.size,
            height: widget.size,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: appBorder),
              boxShadow: isLight
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _AvatarImage(url: _displayUrl, size: widget.size),
                  if (isUploading)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.24),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.canEdit)
            Positioned(
              right: -2,
              bottom: -2,
              child: GestureDetector(
                onTap: isUploading ? null : _openActions,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: appBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: appBorder),
                  ),
                  child: isUploading
                      ? const Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.edit, size: 14, color: appTextSecondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        color: AppColors.appSurface(context),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline,
          color: AppColors.appTextSecondary(context),
          size: 32,
        ),
      );
    }

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final cacheSize = (size * pixelRatio).round();

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 250),
      fadeOutDuration: const Duration(milliseconds: 250),
      memCacheWidth: cacheSize,
      memCacheHeight: cacheSize,
      maxWidthDiskCache: cacheSize,
      maxHeightDiskCache: cacheSize,
      placeholder: (context, _) =>
          Container(color: AppColors.appSurface(context)),
      errorWidget: (context, _, _) => Container(
        color: AppColors.appSurface(context),
        alignment: Alignment.center,
        child: Icon(
          Icons.person_outline,
          color: AppColors.appTextSecondary(context),
          size: 32,
        ),
      ),
    );
  }
}

enum _AvatarAction { gallery, camera, remove }
