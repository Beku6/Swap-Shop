import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<_CartItem> items = [
    _CartItem(
      id: '1',
      title: 'iPhone 15 Pro Titanium',
      price: 999,
      image:
          'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      quantity: 1,
    ),
    _CartItem(
      id: '2',
      title: 'Minimalist Dark Sneakers',
      price: 180,
      image:
          'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      quantity: 1,
    ),
  ];

  void updateQuantity(String id, int delta) {
    setState(() {
      items = items
          .map((item) => item.id == id
              ? item.copyWith(quantity: (item.quantity + delta).clamp(1, 99))
              : item)
          .toList();
    });
  }

  void removeItem(String id) {
    setState(() {
      items = items.where((item) => item.id != id).toList();
    });
  }

  int get total => items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    const double summaryHeight = 156;
    return Scaffold(
      backgroundColor: appBg,
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, items.isNotEmpty ? summaryHeight + 40 : 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cart',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: appTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${items.length} items ready for checkout',
                        style: TextStyle(color: appTextSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.shopping_bag, size: 20, color: appTextSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Column(
              children: [
                for (final item in items) _CartItemTile(item: item, onRemove: removeItem, onUpdate: updateQuantity),
              ],
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 80),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: appTextPrimary.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_bag, size: 32, color: appTextSecondary.withValues(alpha: 0.4)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: TextStyle(color: appTextSecondary, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: items.isNotEmpty
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 512),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: appBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: appTextSecondary,
                              ),
                            ),
                            Text(
                              '\$${_formatPrice(total)}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x26FFFFFF),
                                blurRadius: 40,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                'Continue to Checkout',
                                style: TextStyle(
                                  color: AppColors.black,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18, color: AppColors.black),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final _CartItem item;
  final void Function(String id) onRemove;
  final void Function(String id, int delta) onUpdate;

  const _CartItemTile({required this.item, required this.onRemove, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 96,
              height: 96,
              child: ImageWithFallback(
                src: item.image,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: appTextPrimary.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(item.id),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.delete_outline,
                            size: 18, color: appTextSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatPrice(item.price)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: appBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(
                        icon: Icons.remove,
                        onTap: () => onUpdate(item.id, -1),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: appTextPrimary,
                          ),
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        onTap: () => onUpdate(item.id, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appTextSecondary = AppColors.appTextSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 28,
        height: 28,
        child: Center(
          child: Icon(icon, size: 14, color: appTextSecondary),
        ),
      ),
    );
  }
}

class _CartItem {
  final String id;
  final String title;
  final int price;
  final String image;
  final int quantity;

  const _CartItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.quantity,
  });

  _CartItem copyWith({int? quantity}) {
    return _CartItem(
      id: id,
      title: title,
      price: price,
      image: image,
      quantity: quantity ?? this.quantity,
    );
  }
}

String _formatPrice(int value) {
  final str = value.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (match) => ',');
}
