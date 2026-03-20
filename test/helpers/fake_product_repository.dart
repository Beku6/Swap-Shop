import 'dart:async';
import 'dart:io';

import 'package:swap/features/product/domain/models/product_page.dart';
import 'package:swap/features/product/domain/repositories/product_repository.dart';
import 'package:swap/features/shared/domain/models/product.dart';

class FakeProductRepository implements ProductRepository {
  final List<Product> _items;

  FakeProductRepository({List<Product> seed = const []}) : _items = [...seed];

  @override
  Stream<ProductPage> watchProductsPage({int limit = 20}) {
    return Stream.value(_pageFor(limit: limit));
  }

  @override
  Future<ProductPage> fetchProductsPage({int limit = 20, ProductCursor? startAfter}) async {
    return _pageFor(limit: limit, startAfter: startAfter);
  }

  @override
  Stream<List<Product>> watchProductsByOwner(String ownerId) {
    return Stream.value(_items.where((item) => item.ownerId == ownerId).toList());
  }

  @override
  Stream<Product?> watchProduct(String id) {
    final match = _items.where((item) => item.id == id).toList();
    return Stream.value(match.isEmpty ? null : match.first);
  }

  @override
  Future<Product> getProduct(String id) async {
    return _items.firstWhere((item) => item.id == id);
  }

  @override
  Future<void> addProduct(
    Product product, {
    List<File> images = const [],
    void Function(double progress)? onProgress,
  }) async {
    final nextId = product.id.isEmpty ? 'p${_items.length + 1}' : product.id;
    _items.add(product.copyWith(id: nextId));
    onProgress?.call(1.0);
  }

  @override
  Future<void> updateProduct(Product product) async {
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index == -1) return;
    _items[index] = product;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _items.removeWhere((item) => item.id == id);
  }

  ProductPage _pageFor({required int limit, ProductCursor? startAfter}) {
    final sorted = [..._items]
      ..sort((a, b) {
        final dateCompare = b.createdAt.compareTo(a.createdAt);
        if (dateCompare != 0) return dateCompare;
        return b.id.compareTo(a.id);
      });

    var startIndex = 0;
    if (startAfter != null) {
      final index = sorted.indexWhere((item) => item.id == startAfter.id);
      if (index != -1) {
        startIndex = index + 1;
      }
    }

    final slice = sorted.skip(startIndex).take(limit).toList();
    final cursor = slice.length == limit
        ? ProductCursor(createdAt: slice.last.createdAt, id: slice.last.id)
        : null;
    return ProductPage(items: slice, nextCursor: cursor);
  }

}
