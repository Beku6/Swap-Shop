import '../exceptions/product_upload_exception.dart';

class ProductImageUploadRules {
  ProductImageUploadRules._();

  static const int minImages = 1;
  static const int maxImages = 8;
  static const int maxWidth = 1440;
  static const int jpegQuality = 82;
  static const int maxProcessedBytes = 5 * 1024 * 1024;

  static void validateImageCount(int count) {
    if (count < minImages) {
      throw const ProductUploadException('Please add at least one image.');
    }
    if (count > maxImages) {
      throw const ProductUploadException(
        'You can upload up to 8 images per product.',
      );
    }
  }

  static void validateProcessedSize(int sizeInBytes) {
    if (sizeInBytes > maxProcessedBytes) {
      throw const ProductUploadException(
        'Each image must be 5 MB or smaller after processing.',
      );
    }
  }
}
