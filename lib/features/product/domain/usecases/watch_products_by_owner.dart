import '../../../shared/domain/models/product.dart';
import '../repositories/product_repository.dart';

class WatchProductsByOwner {
  final ProductRepository _repository;

  const WatchProductsByOwner(this._repository);

  Stream<List<Product>> call(String ownerId) {
    return _repository.watchProductsByOwner(ownerId);
  }
}
