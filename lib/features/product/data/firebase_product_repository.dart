import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/firestore_error_utils.dart';
import '../../../core/observability/app_analytics.dart';
import '../../shared/domain/models/product.dart';
import 'services/product_image_upload_service.dart';
import '../domain/models/product_page.dart';
import '../domain/repositories/product_repository.dart';

class FirebaseProductRepository implements ProductRepository {
  final FirebaseFirestore _firestore;
  final ProductImageUploadService _uploadService;
  final AppAnalytics _analytics;

  FirebaseProductRepository(
    this._firestore,
    this._uploadService,
    this._analytics,
  );

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('products');

  Query<Map<String, dynamic>> _baseQuery() {
    return _collection
        .orderBy('createdAt', descending: true)
        .orderBy(FieldPath.documentId, descending: true);
  }

  @override
  Stream<ProductPage> watchProductsPage({int limit = 20}) async* {
    try {
      yield* _baseQuery().limit(limit).snapshots().map((snapshot) {
        final items = snapshot.docs.map(_fromDoc).toList();
        final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
        final cursor = _cursorFromDoc(last);
        return ProductPage(items: items, nextCursor: cursor);
      });
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'products.watchProductsPage',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<ProductPage> fetchProductsPage({
    int limit = 20,
    ProductCursor? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _baseQuery().limit(limit);
      if (startAfter != null) {
        query = query.startAfter([
          Timestamp.fromDate(startAfter.createdAt),
          startAfter.id,
        ]);
      }
      final snapshot = await query.get();
      final items = snapshot.docs.map(_fromDoc).toList();
      final last = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final cursor = _cursorFromDoc(last);
      return ProductPage(items: items, nextCursor: cursor);
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'products.fetchProductsPage',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Stream<List<Product>> watchProductsByOwner(String ownerId) async* {
    try {
      yield* _collection
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
      return;
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'products.watchProductsByOwner',
        error: error,
        stackTrace: stackTrace,
      );

      if (error.code != 'failed-precondition') {
        rethrow;
      }
    }

    // Fallback for environments where composite index is not created yet.
    yield* _collection.where('ownerId', isEqualTo: ownerId).snapshots().map((
      snapshot,
    ) {
      final items = snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  @override
  Stream<Product?> watchProduct(String id) async* {
    try {
      yield* _collection.doc(id).snapshots().map((snapshot) {
        if (!snapshot.exists) return null;
        final data = snapshot.data();
        if (data == null) return null;
        return _fromDoc(snapshot);
      });
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'products.watchProduct',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(String id) async {
    try {
      final doc = await _collection.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        throw StateError('Product not found');
      }
      return _fromDoc(doc);
    } on FirebaseException catch (error, stackTrace) {
      logFirestoreQueryError(
        queryName: 'products.getProduct',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<void> addProduct(
    Product product, {
    List<File> images = const [],
    void Function(double progress)? onProgress,
  }) async {
    final docRef = product.id.isEmpty
        ? _collection.doc()
        : _collection.doc(product.id);
    final productId = docRef.id;

    List<String> imageUrls = product.imageUrls;
    List<UploadedProductImage> uploadedImages = const [];

    if (images.isNotEmpty) {
      uploadedImages = await _uploadService.uploadImages(
        ownerId: product.ownerId,
        productId: productId,
        images: images,
        onProgress: onProgress,
      );
      imageUrls = uploadedImages.map((image) => image.publicUrl).toList();
    }

    try {
      await docRef.set({
        'ownerId': product.ownerId,
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'category': product.category,
        'imageUrls': imageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'likesCount': product.likesCount,
        'isAvailable': product.isAvailable,
        'isForSwap': product.isForSwap,
      });
    } catch (_) {
      await _uploadService.rollback(uploadedImages);
      rethrow;
    }

    await _analytics.logAddProduct(
      productId: productId,
      category: product.category,
    );
  }

  @override
  Future<void> updateProduct(Product product) async {
    await _collection.doc(product.id).update({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'imageUrls': product.imageUrls,
      'likesCount': product.likesCount,
      'isAvailable': product.isAvailable,
      'isForSwap': product.isForSwap,
    });
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _collection.doc(id).delete();
  }

  Product _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
        ? createdAtRaw
        : DateTime.now();

    return Product(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.round() ?? 0,
      category: data['category'] as String? ?? '',
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      createdAt: createdAt,
      likesCount: (data['likesCount'] as num?)?.round() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
      isForSwap: data['isForSwap'] as bool? ?? false,
    );
  }

  ProductCursor? _cursorFromDoc(DocumentSnapshot<Map<String, dynamic>>? doc) {
    if (doc == null) return null;
    final data = doc.data();
    if (data == null) return null;
    final createdAtRaw = data['createdAt'];
    final createdAt = createdAtRaw is Timestamp
        ? createdAtRaw.toDate()
        : createdAtRaw is DateTime
        ? createdAtRaw
        : DateTime.now();
    return ProductCursor(createdAt: createdAt, id: doc.id);
  }
}
