import '../../../shared/domain/models/cart_item.dart';
import '../repositories/cart_repository.dart';

class AddToCart {
  final CartRepository _repository;

  const AddToCart(this._repository);

  Future<void> call(CartItem item) {
    return _repository.addToCart(item);
  }
}
