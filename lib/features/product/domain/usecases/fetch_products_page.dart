import '../models/product_page.dart';
import '../repositories/product_repository.dart';

class FetchProductsPage {
  final ProductRepository _repository;

  const FetchProductsPage(this._repository);

  Future<ProductPage> call({int limit = 20, ProductCursor? startAfter}) {
    return _repository.fetchProductsPage(limit: limit, startAfter: startAfter);
  }
}
