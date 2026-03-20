import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/cart/domain/usecases/add_to_cart.dart';
import 'package:swap/features/cart/domain/usecases/get_cart.dart';
import 'package:swap/features/cart/domain/usecases/remove_from_cart.dart';
import 'package:swap/features/cart/domain/usecases/update_cart_item.dart';
import 'package:swap/features/shared/domain/models/cart_item.dart';

import '../../../helpers/fake_cart_repository.dart';

void main() {
  CartItem buildItem({
    required String id,
    required String userId,
    int quantity = 1,
  }) {
    return CartItem(
      id: id,
      userId: userId,
      productId: id,
      quantity: quantity,
      productTitle: 'Item $id',
      productPrice: 100,
      productImageUrl: 'https://example.com/$id.png',
    );
  }

  test('add to cart stores item', () async {
    final repo = FakeCartRepository();
    final usecase = AddToCart(repo);
    await usecase(buildItem(id: 'p1', userId: 'u1'));
    final list = await repo.fetchCart('u1');
    expect(list.length, 1);
    expect(list.first.id, 'p1');
  });

  test('get cart streams user items', () async {
    final repo = FakeCartRepository(seed: [
      buildItem(id: 'p1', userId: 'u1'),
      buildItem(id: 'p2', userId: 'u2'),
    ]);
    final usecase = GetCart(repo);
    final items = await usecase('u1').first;
    expect(items.length, 1);
    expect(items.first.userId, 'u1');
  });

  test('update cart item changes quantity', () async {
    final repo = FakeCartRepository(seed: [
      buildItem(id: 'p1', userId: 'u1'),
    ]);
    final usecase = UpdateCartItem(repo);
    await usecase(buildItem(id: 'p1', userId: 'u1', quantity: 4));
    final items = await repo.fetchCart('u1');
    expect(items.first.quantity, 4);
  });

  test('remove from cart deletes item', () async {
    final repo = FakeCartRepository(seed: [
      buildItem(id: 'p1', userId: 'u1'),
    ]);
    final usecase = RemoveFromCart(repo);
    await usecase(userId: 'u1', itemId: 'p1');
    final items = await repo.fetchCart('u1');
    expect(items.isEmpty, true);
  });
}
