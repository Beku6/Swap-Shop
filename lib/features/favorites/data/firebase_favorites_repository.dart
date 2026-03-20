import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/observability/app_analytics.dart';
import '../../shared/domain/models/favorite.dart';
import '../domain/repositories/favorites_repository.dart';

class FirebaseFavoritesRepository implements FavoritesRepository {
  final FirebaseFirestore _firestore;
  final AppAnalytics _analytics;

  FirebaseFavoritesRepository(this._firestore, this._analytics);

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('favorites');
  }

  @override
  Stream<List<Favorite>> watchFavorites(String userId) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<List<Favorite>> fetchFavorites(String userId) async {
    final snapshot = await _collection(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addFavorite(Favorite favorite) async {
    await _collection(favorite.userId).doc(favorite.productId).set({
      'userId': favorite.userId,
      'productId': favorite.productId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await _analytics.logAddFavorite(productId: favorite.productId);
  }

  @override
  Future<void> removeFavorite({required String userId, required String favoriteId}) async {
    await _collection(userId).doc(favoriteId).delete();
  }

  Favorite _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp ? createdAtRaw.toDate() : DateTime.now();
    return Favorite(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      productId: data['productId'] as String? ?? doc.id,
      createdAt: createdAt,
    );
  }
}
