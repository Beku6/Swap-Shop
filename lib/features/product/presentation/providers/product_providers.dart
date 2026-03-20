import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/observability/observability_providers.dart';
import '../../../shared/domain/models/product.dart';
import '../../data/firebase_product_repository.dart';
import '../../data/services/product_image_upload_service.dart';
import '../../domain/models/product_page.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/usecases/add_product.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/usecases/fetch_products_page.dart';
import '../../domain/usecases/get_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import '../../domain/usecases/watch_product.dart';
import '../../domain/usecases/watch_products_by_owner.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final productImageStorageProvider = Provider<ProductImageStorage>((ref) {
  return SupabaseProductImageStorage(ref.watch(supabaseClientProvider));
});

final productImageUploadServiceProvider = Provider<ProductImageUploadService>((
  ref,
) {
  return ProductImageUploadService(ref.watch(productImageStorageProvider));
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return FirebaseProductRepository(
    ref.watch(firestoreProvider),
    ref.watch(productImageUploadServiceProvider),
    ref.watch(appAnalyticsProvider),
  );
});

final getProductsProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

final fetchProductsPageProvider = Provider<FetchProductsPage>((ref) {
  return FetchProductsPage(ref.watch(productRepositoryProvider));
});

final getProductProvider = Provider<GetProduct>((ref) {
  return GetProduct(ref.watch(productRepositoryProvider));
});

final watchProductProvider = Provider<WatchProduct>((ref) {
  return WatchProduct(ref.watch(productRepositoryProvider));
});

final watchProductsByOwnerProvider = Provider<WatchProductsByOwner>((ref) {
  return WatchProductsByOwner(ref.watch(productRepositoryProvider));
});

final addProductProvider = Provider<AddProduct>((ref) {
  return AddProduct(ref.watch(productRepositoryProvider));
});

final updateProductProvider = Provider<UpdateProduct>((ref) {
  return UpdateProduct(ref.watch(productRepositoryProvider));
});

final deleteProductProvider = Provider<DeleteProduct>((ref) {
  return DeleteProduct(ref.watch(productRepositoryProvider));
});

final productStreamProvider = StreamProvider.family<Product?, String>((
  ref,
  id,
) {
  return ref.watch(productRepositoryProvider).watchProduct(id);
});

final productsByOwnerProvider = StreamProvider.family<List<Product>, String>((
  ref,
  ownerId,
) {
  return ref.watch(productRepositoryProvider).watchProductsByOwner(ownerId);
});

final productFeedControllerProvider =
    StateNotifierProvider<ProductFeedController, ProductFeedState>((ref) {
      return ProductFeedController(
        getProducts: ref.watch(getProductsProvider),
        fetchProductsPage: ref.watch(fetchProductsPageProvider),
      );
    });

class ProductFeedState {
  final List<Product> items;
  final ProductCursor? cursor;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;

  const ProductFeedState({
    this.items = const [],
    this.cursor,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  ProductFeedState copyWith({
    List<Product>? items,
    ProductCursor? cursor,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
  }) {
    return ProductFeedState(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class ProductFeedController extends StateNotifier<ProductFeedState> {
  static const int _pageSize = 12;

  final GetProducts _getProducts;
  final FetchProductsPage _fetchProductsPage;
  StreamSubscription<ProductPage>? _subscription;

  ProductFeedController({
    required GetProducts getProducts,
    required FetchProductsPage fetchProductsPage,
  }) : _getProducts = getProducts,
       _fetchProductsPage = fetchProductsPage,
       super(const ProductFeedState()) {
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _getProducts(limit: _pageSize).listen(
      (page) {
        final incoming = page.items;
        final existing = state.items;
        final incomingIds = {for (final item in incoming) item.id};
        final merged = [
          ...incoming,
          ...existing.where((item) => !incomingIds.contains(item.id)),
        ];
        state = state.copyWith(
          items: merged,
          cursor: page.nextCursor,
          isLoading: false,
          hasMore: page.nextCursor != null,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(isLoading: false, error: error);
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    final cursor = state.cursor;
    if (cursor == null) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _fetchProductsPage(
        limit: _pageSize,
        startAfter: cursor,
      );
      final existingIds = {for (final item in state.items) item.id};
      final nextItems = [
        ...state.items,
        ...page.items.where((item) => !existingIds.contains(item.id)),
      ];
      state = state.copyWith(
        items: nextItems,
        cursor: page.nextCursor,
        isLoadingMore: false,
        hasMore: page.nextCursor != null,
      );
    } catch (error) {
      state = state.copyWith(isLoadingMore: false, error: error);
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
