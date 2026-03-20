import '../repositories/product_repository.dart';

class DeleteProduct {
  final ProductRepository _repository;

  const DeleteProduct(this._repository);

  Future<void> call(String id) {
    return _repository.deleteProduct(id);
  }
}
