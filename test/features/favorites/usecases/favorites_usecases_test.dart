import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/favorites/domain/usecases/add_favorite.dart';
import 'package:swap/features/favorites/domain/usecases/get_favorites.dart';
import 'package:swap/features/favorites/domain/usecases/remove_favorite.dart';
import 'package:swap/features/shared/domain/models/favorite.dart';

import '../../../helpers/fake_favorites_repository.dart';

void main() {
  Favorite buildFavorite({
    required String userId,
    required String productId,
  }) {
    return Favorite(
      id: productId,
      userId: userId,
      productId: productId,
      createdAt: DateTime.now(),
    );
  }

  test('add favorite stores product', () async {
    final repo = FakeFavoritesRepository();
    final usecase = AddFavorite(repo);
    await usecase(buildFavorite(userId: 'u1', productId: 'p1'));
    final items = await repo.fetchFavorites('u1');
    expect(items.length, 1);
    expect(items.first.productId, 'p1');
  });

  test('get favorites streams user favorites', () async {
    final repo = FakeFavoritesRepository(seed: [
      buildFavorite(userId: 'u1', productId: 'p1'),
      buildFavorite(userId: 'u2', productId: 'p2'),
    ]);
    final usecase = GetFavorites(repo);
    final items = await usecase('u1').first;
    expect(items.length, 1);
    expect(items.first.userId, 'u1');
  });

  test('remove favorite deletes product', () async {
    final repo = FakeFavoritesRepository(seed: [
      buildFavorite(userId: 'u1', productId: 'p1'),
    ]);
    final usecase = RemoveFavorite(repo);
    await usecase(userId: 'u1', favoriteId: 'p1');
    final items = await repo.fetchFavorites('u1');
    expect(items.isEmpty, true);
  });
}
