import 'dart:io';

import '../../../shared/domain/models/product.dart';
import '../models/product_page.dart';

abstract class ProductRepository {
  Stream<ProductPage> watchProductsPage({int limit = 20});
  Future<ProductPage> fetchProductsPage({int limit = 20, ProductCursor? startAfter});
  Stream<List<Product>> watchProductsByOwner(String ownerId);
  Stream<Product?> watchProduct(String id);
  Future<Product> getProduct(String id);
  Future<void> addProduct(
    Product product, {
    List<File> images = const [],
    void Function(double progress)? onProgress,
  });
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
