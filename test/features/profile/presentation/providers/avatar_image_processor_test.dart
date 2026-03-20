import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:swap/features/profile/presentation/providers/profile_providers.dart';

void main() {
  group('AvatarImageProcessor', () {
    test('processes image to square jpeg within configured max size', () {
      final processor = AvatarImageProcessor();
      final source = _buildPng(width: 1400, height: 1100);

      final output = processor.process(source);
      final decoded = img.decodeJpg(output);

      expect(decoded, isNotNull);
      expect(decoded!.width, 1024);
      expect(decoded.height, 1024);
      expect(output.lengthInBytes, lessThanOrEqualTo(512 * 1024));
    });

    test('throws validation error for small input image', () {
      final processor = AvatarImageProcessor();
      final source = _buildPng(width: 320, height: 320);

      expect(
        () => processor.process(source),
        throwsA(isA<AvatarValidationException>()),
      );
    });
  });
}

Uint8List _buildPng({required int width, required int height}) {
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final channel = ((x + y) % 255).toInt();
      image.setPixelRgb(x, y, channel, 120, 255 - channel);
    }
  }
  return Uint8List.fromList(img.encodePng(image));
}
