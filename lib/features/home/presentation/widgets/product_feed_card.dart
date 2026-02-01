import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';

class ProductFeedCard extends StatefulWidget {
  final Map<String, dynamic> product;
  final VoidCallback? onAction;

  const ProductFeedCard({super.key, required this.product, this.onAction});

  @override
  State<ProductFeedCard> createState() => _ProductFeedCardState();
}

class _ProductFeedCardState extends State<ProductFeedCard> {
  late final PageController _controller;
  final ValueNotifier<int> _activeIndex = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
    _controller = PageController();
  }

  @override
  void dispose() {
    _controller.dispose();
    _activeIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);
    final appCardAction = AppColors.appCardAction(context);

    final product = widget.product;
    final title = product['title'] as String? ?? '';
    final description = product['description'] as String? ??
        'A pristine example of design excellence. This piece is part of a curated collection.';
    final price = _formatPrice(product['price']);
    final canSwap = product['canSwap'] == true;
    final seller = product['seller'] as Map<String, dynamic>? ?? {};
    final sellerName = seller['name'] as String? ?? 'Seller';
    final sellerAvatar = seller['avatar'] as String? ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${product['id']}';
    final timePosted = product['timestamp'] as String? ?? '1 day ago';
    final isCurrentUser = sellerName == 'Felix Anderson';
    final List<dynamic> images = (product['images'] as List<dynamic>?) ?? [product['image']];

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: appBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: appTextPrimary.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(color: appBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ImageWithFallback(src: sellerAvatar),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              sellerName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                                height: 1.1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (seller['verified'] == true) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.verified, size: 14, color: AppColors.blue500),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timePosted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: appTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _HeaderIconButton(
                      icon: Icons.send,
                      color: appTextSecondary,
                      onTap: () {},
                    ),
                    _HeaderIconButton(
                      icon: Icons.message_outlined,
                      color: appTextSecondary,
                      onTap: () {},
                    ),
                    _HeaderIconButton(
                      icon: Icons.favorite_border,
                      color: appTextSecondary,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: appTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: AspectRatio(
                      aspectRatio: 1.8,
                      child: PageView.builder(
                        controller: _controller,
                        onPageChanged: (index) => _activeIndex.value = index,
                        itemCount: images.length,
                        itemBuilder: (context, index) => ImageWithFallback(
                          src: images[index] as String?,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.6),
                          border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '\$$price',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _activeIndex,
                    builder: (context, activeIndex, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: index == activeIndex ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: index == activeIndex
                              ? appTextPrimary
                              : appTextPrimary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: canSwap && !isCurrentUser
                ? Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          label: 'Exchange',
                          background: appCardAction,
                          foreground: appTextPrimary,
                          borderColor: appBorder,
                          icon: Icons.repeat,
                          iconColor: AppColors.blue400,
                          onTap: widget.onAction,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionButton(
                          label: 'Add to Cart',
                          background: AppColors.white,
                          foreground: AppColors.black,
                          icon: Icons.shopping_cart,
                          iconColor: AppColors.black,
                          onTap: widget.onAction,
                        ),
                      ),
                    ],
                  )
                : _ActionButton(
                    label: 'Add to Cart',
                    background: AppColors.white,
                    foreground: AppColors.black,
                    icon: Icons.shopping_cart,
                    iconColor: AppColors.black,
                    onTap: widget.onAction,
                  ),
          ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _HeaderIconButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 20, color: color),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.icon,
    required this.iconColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(dynamic value) {
  if (value == null) return '';
  final number = value is num ? value.round() : int.tryParse(value.toString()) ?? 0;
  final str = number.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (match) => ',');
}
