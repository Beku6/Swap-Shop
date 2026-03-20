import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/product/domain/exceptions/product_upload_exception.dart';
import 'package:swap/features/product/domain/services/product_image_upload_rules.dart';

void main() {
  test('validateImageCount rejects when no image is selected', () {
    expect(
      () => ProductImageUploadRules.validateImageCount(0),
      throwsA(isA<ProductUploadException>()),
    );
  });

  test('validateImageCount rejects when more than 8 images are selected', () {
    expect(
      () => ProductImageUploadRules.validateImageCount(9),
      throwsA(isA<ProductUploadException>()),
    );
  });

  test('validateProcessedSize rejects files above 5 MB', () {
    expect(
      () => ProductImageUploadRules.validateProcessedSize(
        ProductImageUploadRules.maxProcessedBytes + 1,
      ),
      throwsA(isA<ProductUploadException>()),
    );
  });
}
