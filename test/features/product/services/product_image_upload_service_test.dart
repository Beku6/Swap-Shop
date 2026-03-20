import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:swap/features/product/data/services/product_image_upload_service.dart';
import 'package:swap/features/product/domain/exceptions/product_upload_exception.dart';

void main() {
  test('processes image and uploads resized jpeg', () async {
    final storage = _FakeProductImageStorage();
    final service = ProductImageUploadService(storage);
    final file = await _createTempImageFile(width: 2400, height: 1200);

    final uploaded = await service.uploadImages(
      ownerId: 'user-1',
      productId: 'prod-1',
      images: [file],
    );

    expect(uploaded, hasLength(1));
    final bytes = storage.uploadedBytes.single;
    final decoded = img.decodeImage(bytes);
    expect(decoded, isNotNull);
    expect(decoded!.width <= 1440, isTrue);
    expect(decoded.height, closeTo(720, 2));
  });

  test('retries transient upload failures up to success', () async {
    var attempts = 0;
    final storage = _FakeProductImageStorage(
      onUpload: (objectPath, bytes) async {
        attempts++;
        if (attempts < 3) {
          throw TimeoutException('network timeout');
        }
      },
    );

    final service = ProductImageUploadService(
      storage,
      processImageBytes: (_) async => Uint8List.fromList([1, 2, 3]),
    );

    final file = await _createTempImageFile(width: 1200, height: 1200);
    final uploaded = await service.uploadImages(
      ownerId: 'user-1',
      productId: 'prod-1',
      images: [file],
    );

    expect(uploaded, hasLength(1));
    expect(attempts, 3);
  });

  test(
    'rolls back previously uploaded files when a later upload fails',
    () async {
      var uploadCount = 0;
      final storage = _FakeProductImageStorage(
        onUpload: (objectPath, bytes) async {
          uploadCount++;
          if (uploadCount == 2) {
            throw const _PermanentUploadException();
          }
        },
      );

      final service = ProductImageUploadService(
        storage,
        processImageBytes: (_) async => Uint8List.fromList([1, 2, 3]),
      );

      final file = await _createTempImageFile(width: 1200, height: 1200);

      await expectLater(
        service.uploadImages(
          ownerId: 'user-1',
          productId: 'prod-1',
          images: [file, file],
        ),
        throwsA(isA<ProductUploadException>()),
      );

      expect(storage.deletedPaths, hasLength(1));
    },
  );
}

class _FakeProductImageStorage implements ProductImageStorage {
  final Future<void> Function(String objectPath, Uint8List bytes)? onUpload;
  final List<Uint8List> uploadedBytes = [];
  final List<String> deletedPaths = [];

  _FakeProductImageStorage({this.onUpload});

  @override
  Future<void> uploadBinary({
    required String objectPath,
    required Uint8List bytes,
  }) async {
    await onUpload?.call(objectPath, bytes);
    uploadedBytes.add(bytes);
  }

  @override
  Future<void> deleteObjects(List<String> objectPaths) async {
    deletedPaths.addAll(objectPaths);
  }

  @override
  String getPublicUrl(String objectPath) {
    return 'https://example.com/$objectPath';
  }
}

class _PermanentUploadException implements Exception {
  const _PermanentUploadException();
}

Future<File> _createTempImageFile({
  required int width,
  required int height,
}) async {
  final directory = await Directory.systemTemp.createTemp('swap-upload-test');
  final file = File('${directory.path}/image.jpg');
  final image = img.Image(width: width, height: height);
  img.fill(image, color: img.ColorRgb8(90, 140, 220));
  final bytes = img.encodeJpg(image, quality: 100);
  await file.writeAsBytes(bytes, flush: true);
  return file;
}
