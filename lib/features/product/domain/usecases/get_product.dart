import '../../../shared/domain/models/product.dart';
import '../repositories/product_repository.dart';

class GetProduct {
  final ProductRepository _repository;

  const GetProduct(this._repository);

  Future<Product> call(String id) {
    return _repository.getProduct(id);
  }
}
