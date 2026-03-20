import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/supabase_constants.dart';
import '../../domain/exceptions/product_upload_exception.dart';
import '../../domain/services/product_image_upload_rules.dart';

typedef ProcessImageBytes = Future<Uint8List> Function(File file);

void _logStorageDebug(String message) {
  if (kDebugMode || kProfileMode) {
    developer.log(message);
  }
}

class UploadedProductImage {
  final String objectPath;
  final String publicUrl;

  const UploadedProductImage({
    required this.objectPath,
    required this.publicUrl,
  });
}

abstract class ProductImageStorage {
  Future<void> uploadBinary({
    required String objectPath,
    required Uint8List bytes,
  });

  Future<void> deleteObjects(List<String> objectPaths);

  String getPublicUrl(String objectPath);
}

class SupabaseProductImageStorage implements ProductImageStorage {
  final SupabaseClient _client;

  SupabaseProductImageStorage(this._client);

  @override
  Future<void> uploadBinary({
    required String objectPath,
    required Uint8List bytes,
  }) async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;
    _logStorageDebug(
      'Supabase uploadBinary start bucket=${SupabaseConstants.productImagesBucket} path=$objectPath bytes=${bytes.lengthInBytes} contentType=image/jpeg sessionPresent=${session != null} userId=${user?.id ?? 'null'}',
    );
    _logStorageDebug('Supabase auth.currentSession=$session');
    _logStorageDebug('Supabase auth.currentUser=$user');
    try {
      await _client.storage
          .from(SupabaseConstants.productImagesBucket)
          .uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: false,
            ),
          );
    } on StorageException catch (error, stackTrace) {
      _logStorageDebug(
        'Supabase uploadBinary failed bucket=${SupabaseConstants.productImagesBucket} path=$objectPath status=${error.statusCode ?? 'unknown'} message=${error.message} error=${error.error ?? 'null'}',
      );
      _logStorageDebug(
        'Supabase uploadBinary exception details: message=${error.message} statusCode=${error.statusCode ?? 'unknown'} error=${error.error ?? 'null'}',
      );
      _logStorageDebug('Supabase uploadBinary stackTrace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<void> deleteObjects(List<String> objectPaths) async {
    if (objectPaths.isEmpty) return;
    await _client.storage
        .from(SupabaseConstants.productImagesBucket)
        .remove(objectPaths);
  }

  @override
  String getPublicUrl(String objectPath) {
    return _client.storage
        .from(SupabaseConstants.productImagesBucket)
        .getPublicUrl(objectPath);
  }
}

class ProductImageUploadService {
  static const int _maxRetries = 3;
  static const Duration _perFileTimeout = Duration(seconds: 30);

  final ProductImageStorage _storage;
  final ProcessImageBytes _processImageBytes;

  ProductImageUploadService(
    this._storage, {
    ProcessImageBytes? processImageBytes,
  }) : _processImageBytes = processImageBytes ?? _defaultProcessImageBytes;

  Future<List<UploadedProductImage>> uploadImages({
    required String ownerId,
    required String productId,
    required List<File> images,
    void Function(double progress)? onProgress,
  }) async {
    ProductImageUploadRules.validateImageCount(images.length);

    final uploaded = <UploadedProductImage>[];

    for (var i = 0; i < images.length; i++) {
      final file = images[i];
      _logStorageDebug('Product image upload local file path=${file.path}');
      final processed = await _processImageBytes(file);
      ProductImageUploadRules.validateProcessedSize(processed.lengthInBytes);

      final objectPath =
          '$ownerId/$productId/${DateTime.now().microsecondsSinceEpoch}_$i.jpg';
      _logStorageDebug(
        'Product image upload storage object path=$objectPath bucket=${SupabaseConstants.productImagesBucket}',
      );

      try {
        await _uploadWithRetry(objectPath: objectPath, bytes: processed);
      } catch (error, stackTrace) {
        _logStorageDebug(
          'Product image upload failed for $objectPath: $error (stackTrace logged below)',
        );
        _logStorageDebug('$stackTrace');
        await rollback(uploaded);
        throw _mapUploadException(error);
      }

      uploaded.add(
        UploadedProductImage(
          objectPath: objectPath,
          publicUrl: _storage.getPublicUrl(objectPath),
        ),
      );
      onProgress?.call((i + 1) / images.length);
    }

    return uploaded;
  }

  Future<void> rollback(List<UploadedProductImage> uploadedImages) async {
    if (uploadedImages.isEmpty) return;
    try {
      await _storage.deleteObjects(
        uploadedImages.map((image) => image.objectPath).toList(),
      );
    } catch (_) {
      // Best effort rollback: ignore cleanup failures to preserve root error.
    }
  }

  Future<void> _uploadWithRetry({
    required String objectPath,
    required Uint8List bytes,
  }) async {
    var attempts = 0;
    while (true) {
      attempts++;
      try {
        await _storage
            .uploadBinary(objectPath: objectPath, bytes: bytes)
            .timeout(_perFileTimeout);
        return;
      } catch (error) {
        if (error is StorageException) {
          _logStorageDebug(
            'Supabase upload attempt $attempts failed for $objectPath with status=${error.statusCode ?? 'unknown'} message=${error.message}',
          );
        } else {
          _logStorageDebug(
            'Supabase upload attempt $attempts failed for $objectPath: $error',
          );
        }
        if (attempts >= _maxRetries || !_isTransient(error)) {
          rethrow;
        }
        await Future<void>.delayed(Duration(milliseconds: 250 * attempts));
      }
    }
  }

  ProductUploadException _mapUploadException(Object error) {
    if (error is ProductUploadException) {
      return error;
    }
    if (error is TimeoutException || error is SocketException) {
      return const ProductUploadException(
        'Upload timed out. Please check your connection and try again.',
      );
    }
    if (error is StorageException) {
      final status = (error.statusCode ?? '').toString();
      final message = error.message.toLowerCase();
      if (_isBucketMissing(status: status, message: message)) {
        return const ProductUploadException(
          'Supabase bucket not found: product-images.',
        );
      }
      if (_isPolicyDenied(status: status, message: message)) {
        return const ProductUploadException(
          'Supabase Storage policy denied upload/read for bucket "product-images".',
        );
      }
      return ProductUploadException(
        'Supabase upload failed (${status.isEmpty ? 'unknown' : status}): ${error.message}',
      );
    }
    return const ProductUploadException(
      'Image upload failed. Please check your connection and try again.',
    );
  }

  bool _isBucketMissing({required String status, required String message}) {
    return status == '404' ||
        message.contains('bucket not found') ||
        (message.contains('bucket') && message.contains('not found'));
  }

  bool _isPolicyDenied({required String status, required String message}) {
    return status == '401' ||
        status == '403' ||
        message.contains('policy') ||
        message.contains('forbidden') ||
        message.contains('permission denied') ||
        message.contains('row-level security') ||
        message.contains('not allowed');
  }

  bool _isTransient(Object error) {
    if (error is TimeoutException) return true;
    if (error is SocketException) return true;
    if (error is StorageException) {
      final code = (error.statusCode ?? '').toString();
      if (code.startsWith('5') || code == '429') return true;
      final message = error.message.toLowerCase();
      return message.contains('timeout') ||
          message.contains('network') ||
          message.contains('temporar');
    }
    return false;
  }

  static Future<Uint8List> _defaultProcessImageBytes(File file) async {
    final sourceBytes = await file.readAsBytes();
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      throw const ProductUploadException(
        'One of the selected images is invalid.',
      );
    }

    final targetWidth = decoded.width > ProductImageUploadRules.maxWidth
        ? ProductImageUploadRules.maxWidth
        : decoded.width;
    final resized = targetWidth == decoded.width
        ? decoded
        : img.copyResize(
            decoded,
            width: targetWidth,
            interpolation: img.Interpolation.average,
          );

    final encoded = img.encodeJpg(
      resized,
      quality: ProductImageUploadRules.jpegQuality,
    );
    if (encoded.isEmpty) {
      throw const ProductUploadException(
        'Failed to process an image before upload.',
      );
    }
    // Re-encoding strips EXIF metadata.
    return Uint8List.fromList(encoded);
  }
}
