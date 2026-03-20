import '../../../shared/domain/models/product.dart';
import '../repositories/product_repository.dart';

class WatchProduct {
  final ProductRepository _repository;

  const WatchProduct(this._repository);

  Stream<Product?> call(String id) {
    return _repository.watchProduct(id);
  }
}
