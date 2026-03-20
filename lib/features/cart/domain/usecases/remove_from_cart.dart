import '../repositories/cart_repository.dart';

class RemoveFromCart {
  final CartRepository _repository;

  const RemoveFromCart(this._repository);

  Future<void> call({
    required String userId,
    required String itemId,
  }) {
    return _repository.removeFromCart(userId: userId, itemId: itemId);
  }
}
