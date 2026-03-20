import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/observability_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../shared/domain/models/cart_item.dart';
import '../../data/firebase_cart_repository.dart';
import '../../domain/repositories/cart_repository.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/get_cart.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_cart_item.dart';

final cartFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return FirebaseCartRepository(
    ref.watch(cartFirestoreProvider),
    ref.watch(appAnalyticsProvider),
  );
});

final addToCartProvider = Provider<AddToCart>((ref) {
  return AddToCart(ref.watch(cartRepositoryProvider));
});

final getCartProvider = Provider<GetCart>((ref) {
  return GetCart(ref.watch(cartRepositoryProvider));
});

final removeFromCartProvider = Provider<RemoveFromCart>((ref) {
  return RemoveFromCart(ref.watch(cartRepositoryProvider));
});

final updateCartItemProvider = Provider<UpdateCartItem>((ref) {
  return UpdateCartItem(ref.watch(cartRepositoryProvider));
});

final cartItemsProvider = StreamProvider.family<List<CartItem>, String>((
  ref,
  userId,
) {
  final currentUserId = ref.watch(authControllerProvider).user?.id;
  if (currentUserId == null || currentUserId != userId) {
    return Stream.value(const <CartItem>[]);
  }
  return ref.watch(getCartProvider).call(userId);
});
