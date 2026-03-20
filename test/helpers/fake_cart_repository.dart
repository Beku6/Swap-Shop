import 'package:swap/features/cart/domain/repositories/cart_repository.dart';
import 'package:swap/features/shared/domain/models/cart_item.dart';

class FakeCartRepository implements CartRepository {
  final List<CartItem> _items;

  FakeCartRepository({List<CartItem> seed = const []}) : _items = [...seed];

  @override
  Stream<List<CartItem>> watchCart(String userId) {
    return Stream.value(_items.where((item) => item.userId == userId).toList());
  }

  @override
  Future<List<CartItem>> fetchCart(String userId) async {
    return _items.where((item) => item.userId == userId).toList();
  }

  @override
  Future<void> addToCart(CartItem item) async {
    final index = _items.indexWhere((entry) => entry.userId == item.userId && entry.id == item.id);
    if (index == -1) {
      _items.add(item);
      return;
    }
    final current = _items[index];
    _items[index] = current.copyWith(quantity: current.quantity + item.quantity);
  }

  @override
  Future<void> updateCartItem(CartItem item) async {
    final index = _items.indexWhere((entry) => entry.userId == item.userId && entry.id == item.id);
    if (index == -1) return;
    _items[index] = item;
  }

  @override
  Future<void> removeFromCart({required String userId, required String itemId}) async {
    _items.removeWhere((entry) => entry.userId == userId && entry.id == itemId);
  }
}
