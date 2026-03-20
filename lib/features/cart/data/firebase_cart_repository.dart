import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/observability/app_analytics.dart';
import '../../shared/domain/models/cart_item.dart';
import '../domain/repositories/cart_repository.dart';

class FirebaseCartRepository implements CartRepository {
  final FirebaseFirestore _firestore;
  final AppAnalytics _analytics;

  FirebaseCartRepository(this._firestore, this._analytics);

  CollectionReference<Map<String, dynamic>> _collection(String userId) {
    return _firestore.collection('users').doc(userId).collection('cart');
  }

  @override
  Stream<List<CartItem>> watchCart(String userId) {
    return _collection(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<List<CartItem>> fetchCart(String userId) async {
    final snapshot = await _collection(userId).orderBy('createdAt', descending: true).get();
    return snapshot.docs.map(_fromDoc).toList();
  }

  @override
  Future<void> addToCart(CartItem item) async {
    final doc = _collection(item.userId).doc(item.productId);
    final existing = await doc.get();
    if (existing.exists) {
      await doc.update({
        'quantity': FieldValue.increment(item.quantity),
        'productTitle': item.productTitle,
        'productPrice': item.productPrice,
        'productImageUrl': item.productImageUrl,
      });
      await _analytics.logAddToCart(productId: item.productId, quantity: item.quantity);
      return;
    }

    await doc.set({
      'userId': item.userId,
      'productId': item.productId,
      'quantity': item.quantity,
      'productTitle': item.productTitle,
      'productPrice': item.productPrice,
      'productImageUrl': item.productImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _analytics.logAddToCart(productId: item.productId, quantity: item.quantity);
  }

  @override
  Future<void> updateCartItem(CartItem item) async {
    await _collection(item.userId).doc(item.id).update({
      'quantity': item.quantity,
    });
  }

  @override
  Future<void> removeFromCart({required String userId, required String itemId}) async {
    await _collection(userId).doc(itemId).delete();
  }

  CartItem _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp ? createdAtRaw.toDate() : null;
    return CartItem(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      productId: data['productId'] as String? ?? doc.id,
      quantity: (data['quantity'] as num?)?.toInt() ?? 1,
      productTitle: data['productTitle'] as String? ?? '',
      productPrice: (data['productPrice'] as num?)?.toInt() ?? 0,
      productImageUrl: data['productImageUrl'] as String?,
      createdAt: createdAt,
    );
  }
}
