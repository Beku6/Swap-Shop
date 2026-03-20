class ProductUploadException implements Exception {
  final String message;

  const ProductUploadException(this.message);

  @override
  String toString() => message;
}
