import '../../../shared/domain/models/product.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  final ProductRepository _repository;

  const UpdateProduct(this._repository);

  Future<void> call(Product product) {
    return _repository.updateProduct(product);
  }
}
