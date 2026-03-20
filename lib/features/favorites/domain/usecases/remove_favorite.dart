import '../repositories/favorites_repository.dart';

class RemoveFavorite {
  final FavoritesRepository _repository;

  const RemoveFavorite(this._repository);

  Future<void> call({
    required String userId,
    required String favoriteId,
  }) {
    return _repository.removeFavorite(userId: userId, favoriteId: favoriteId);
  }
}
