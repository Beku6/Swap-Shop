import '../../../shared/domain/models/favorite.dart';
import '../repositories/favorites_repository.dart';

class GetFavorites {
  final FavoritesRepository _repository;

  const GetFavorites(this._repository);

  Stream<List<Favorite>> call(String userId) {
    return _repository.watchFavorites(userId);
  }
}
