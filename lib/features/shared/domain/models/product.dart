class Product {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final int price;
  final String category;
  final List<String> imageUrls;
  final DateTime createdAt;
  final int likesCount;
  final bool isAvailable;
  final bool isForSwap;

  const Product({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.createdAt,
    required this.likesCount,
    required this.isAvailable,
    required this.isForSwap,
  });

  Product copyWith({
    String? id,
    String? ownerId,
    String? title,
    String? description,
    int? price,
    String? category,
    List<String>? imageUrls,
    DateTime? createdAt,
    int? likesCount,
    bool? isAvailable,
    bool? isForSwap,
  }) {
    return Product(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      likesCount: likesCount ?? this.likesCount,
      isAvailable: isAvailable ?? this.isAvailable,
      isForSwap: isForSwap ?? this.isForSwap,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'createdAt': createdAt,
      'likesCount': likesCount,
      'isAvailable': isAvailable,
      'isForSwap': isForSwap,
    };
  }

  factory Product.fromMap({
    required String id,
    required Map<String, dynamic> data,
  }) {
    return Product(
      id: id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.round() ?? 0,
      category: data['category'] as String? ?? '',
      imageUrls: (data['imageUrls'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .toList(),
      createdAt: data['createdAt'] as DateTime? ?? DateTime.fromMillisecondsSinceEpoch(0),
      likesCount: (data['likesCount'] as num?)?.round() ?? 0,
      isAvailable: data['isAvailable'] as bool? ?? true,
      isForSwap: data['isForSwap'] as bool? ?? false,
    );
  }
}
