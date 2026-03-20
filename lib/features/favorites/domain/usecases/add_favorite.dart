import '../../../shared/domain/models/favorite.dart';
import '../repositories/favorites_repository.dart';

class AddFavorite {
  final FavoritesRepository _repository;

  const AddFavorite(this._repository);

  Future<void> call(Favorite favorite) {
    return _repository.addFavorite(favorite);
  }
}
