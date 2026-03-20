class Order {
  final String id;
  final String userId;
  final List<String> productIds;
  final int totalAmount;
  final String status;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.userId,
    required this.productIds,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}
