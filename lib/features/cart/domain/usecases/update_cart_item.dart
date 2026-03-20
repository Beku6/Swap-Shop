import '../../../shared/domain/models/cart_item.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItem {
  final CartRepository _repository;

  const UpdateCartItem(this._repository);

  Future<void> call(CartItem item) {
    return _repository.updateCartItem(item);
  }
}
