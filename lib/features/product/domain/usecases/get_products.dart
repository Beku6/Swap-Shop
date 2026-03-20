import '../models/product_page.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  final ProductRepository _repository;

  const GetProducts(this._repository);

  Stream<ProductPage> call({int limit = 20}) {
    return _repository.watchProductsPage(limit: limit);
  }
}
