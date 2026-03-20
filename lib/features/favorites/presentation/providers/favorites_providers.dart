import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/observability_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../shared/domain/models/favorite.dart';
import '../../data/firebase_favorites_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/usecases/add_favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/remove_favorite.dart';

final favoritesFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FirebaseFavoritesRepository(
    ref.watch(favoritesFirestoreProvider),
    ref.watch(appAnalyticsProvider),
  );
});

final addFavoriteProvider = Provider<AddFavorite>((ref) {
  return AddFavorite(ref.watch(favoritesRepositoryProvider));
});

final getFavoritesProvider = Provider<GetFavorites>((ref) {
  return GetFavorites(ref.watch(favoritesRepositoryProvider));
});

final removeFavoriteProvider = Provider<RemoveFavorite>((ref) {
  return RemoveFavorite(ref.watch(favoritesRepositoryProvider));
});

final favoritesProvider = StreamProvider.family<List<Favorite>, String>((
  ref,
  userId,
) {
  final currentUserId = ref.watch(authControllerProvider).user?.id;
  if (currentUserId == null || currentUserId != userId) {
    return Stream.value(const <Favorite>[]);
  }
  return ref.watch(getFavoritesProvider).call(userId);
});

final favoriteIdsProvider = Provider.family<Set<String>, String>((ref, userId) {
  final asyncValue = ref.watch(favoritesProvider(userId));
  return asyncValue.maybeWhen(
    data: (items) => items.map((favorite) => favorite.productId).toSet(),
    orElse: () => <String>{},
  );
});
