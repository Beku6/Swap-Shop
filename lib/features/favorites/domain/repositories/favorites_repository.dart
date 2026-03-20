import '../../../shared/domain/models/favorite.dart';

abstract class FavoritesRepository {
  Stream<List<Favorite>> watchFavorites(String userId);
  Future<List<Favorite>> fetchFavorites(String userId);
  Future<void> addFavorite(Favorite favorite);
  Future<void> removeFavorite({required String userId, required String favoriteId});
}
