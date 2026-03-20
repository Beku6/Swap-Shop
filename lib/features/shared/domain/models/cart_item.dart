class CartItem {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final String productTitle;
  final int productPrice;
  final String? productImageUrl;
  final DateTime? createdAt;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.productTitle,
    required this.productPrice,
    this.productImageUrl,
    this.createdAt,
  });

  CartItem copyWith({
    String? id,
    String? userId,
    String? productId,
    int? quantity,
    String? productTitle,
    int? productPrice,
    String? productImageUrl,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      productTitle: productTitle ?? this.productTitle,
      productPrice: productPrice ?? this.productPrice,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
