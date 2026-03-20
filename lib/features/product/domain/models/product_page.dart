import '../../../shared/domain/models/product.dart';

class ProductCursor {
  final DateTime createdAt;
  final String id;

  const ProductCursor({
    required this.createdAt,
    required this.id,
  });
}

class ProductPage {
  final List<Product> items;
  final ProductCursor? nextCursor;

  const ProductPage({
    required this.items,
    required this.nextCursor,
  });
}
