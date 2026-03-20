import '../../../shared/domain/models/cart_item.dart';
import '../repositories/cart_repository.dart';

class GetCart {
  final CartRepository _repository;

  const GetCart(this._repository);

  Stream<List<CartItem>> call(String userId) {
    return _repository.watchCart(userId);
  }
}
