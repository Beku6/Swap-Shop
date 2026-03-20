import '../../../shared/domain/models/cart_item.dart';

abstract class CartRepository {
  Stream<List<CartItem>> watchCart(String userId);
  Future<List<CartItem>> fetchCart(String userId);
  Future<void> addToCart(CartItem item);
  Future<void> updateCartItem(CartItem item);
  Future<void> removeFromCart({required String userId, required String itemId});
}
