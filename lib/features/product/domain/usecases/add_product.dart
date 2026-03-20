import 'dart:io';

import '../../../shared/domain/models/product.dart';
import '../repositories/product_repository.dart';

class AddProduct {
  final ProductRepository _repository;

  const AddProduct(this._repository);

  Future<void> call({
    required Product product,
    List<File> images = const [],
    void Function(double progress)? onProgress,
  }) {
    return _repository.addProduct(
      product,
      images: images,
      onProgress: onProgress,
    );
  }
}
