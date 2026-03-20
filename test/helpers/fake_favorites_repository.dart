import 'package:swap/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:swap/features/shared/domain/models/favorite.dart';

class FakeFavoritesRepository implements FavoritesRepository {
  final List<Favorite> _items;

  FakeFavoritesRepository({List<Favorite> seed = const []}) : _items = [...seed];

  @override
  Stream<List<Favorite>> watchFavorites(String userId) {
    return Stream.value(_items.where((item) => item.userId == userId).toList());
  }

  @override
  Future<List<Favorite>> fetchFavorites(String userId) async {
    return _items.where((item) => item.userId == userId).toList();
  }

  @override
  Future<void> addFavorite(Favorite favorite) async {
    final exists = _items.any((item) => item.userId == favorite.userId && item.id == favorite.id);
    if (!exists) {
      _items.add(favorite);
    }
  }

  @override
  Future<void> removeFavorite({required String userId, required String favoriteId}) async {
    _items.removeWhere((item) => item.userId == userId && item.id == favoriteId);
  }
}
