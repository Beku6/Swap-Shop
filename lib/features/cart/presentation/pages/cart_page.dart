import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_async_value_builder.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../shared/domain/models/cart_item.dart';
import '../providers/cart_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    final user = ref.watch(authControllerProvider).user;
    final userId = user?.id;
    final cartAsync = userId == null
        ? const AsyncValue<List<CartItem>>.data([])
        : ref.watch(cartItemsProvider(userId));

    const double summaryHeight = 156;

    Future<void> updateQuantity(CartItem item, int delta) async {
      final next = (item.quantity + delta).clamp(1, 99);
      await ref
          .read(updateCartItemProvider)
          .call(item.copyWith(quantity: next));
    }

    Future<void> removeItem(CartItem item) async {
      if (userId == null) return;
      await ref
          .read(removeFromCartProvider)
          .call(userId: userId, itemId: item.id);
    }

    return AppAsyncValueBuilder<List<CartItem>>(
      value: cartAsync,
      onRetry: userId == null
          ? null
          : () => ref.invalidate(cartItemsProvider(userId)),
      errorTitle: 'Unable to load cart',
      loadingBuilder: (context) => Scaffold(
        backgroundColor: appBg,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            children: const [
              SizedBox(height: 120),
              _CartItemSkeleton(),
              _CartItemSkeleton(),
              _CartItemSkeleton(),
            ],
          ),
        ),
      ),
      dataBuilder: (items) {
        if (items.isEmpty) {
          return Scaffold(
            backgroundColor: appBg,
            body: Column(
              children: [
                _CartHeader(
                  itemCount: items.length,
                  appSurface: appSurface,
                  appTextPrimary: appTextPrimary,
                  appTextSecondary: appTextSecondary,
                  horizontalPadding: 20,
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
                              child: AppEmptyState(
                                icon: Icons.shopping_bag_outlined,
                                title: 'Your cart is empty',
                                subtitle: 'Start exploring items nearby',
                                actionLabel: 'Browse items',
                                onAction: () => context.go(Routes.home),
                                enableHaptic: true,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        }

        final total = items.fold<int>(
          0,
          (sum, item) => sum + (item.productPrice * item.quantity),
        );
        return Scaffold(
          backgroundColor: appBg,
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              items.isNotEmpty ? summaryHeight + 40 : 32,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CartHeader(
                  itemCount: items.length,
                  appSurface: appSurface,
                  appTextPrimary: appTextPrimary,
                  appTextSecondary: appTextSecondary,
                ),
                const SizedBox(height: 24),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(
                      item: item,
                      onRemove: () => removeItem(item),
                      onUpdate: (delta) => updateQuantity(item, delta),
                    );
                  },
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
                            AppPressable(
                              onTap: () {},
                              haptic: AppPressableHaptic.medium,
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
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
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 18,
                                      color: AppColors.black,
                                    ),
                                  ],
                                ),
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
      },
    );
  }
}

class _CartItemSkeleton extends StatelessWidget {
  const _CartItemSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: const Row(
        children: [
          AppSkeletonBlock(height: 96, width: 96, radius: 16),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBlock(height: 14, width: 140),
                SizedBox(height: 10),
                AppSkeletonBlock(height: 18, width: 80),
                SizedBox(height: 14),
                AppSkeletonBlock(height: 32, width: 96, radius: 999),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartHeader extends StatelessWidget {
  const _CartHeader({
    required this.itemCount,
    required this.appSurface,
    required this.appTextPrimary,
    required this.appTextSecondary,
    this.horizontalPadding = 0,
  });

  final int itemCount;
  final Color appSurface;
  final Color appTextPrimary;
  final Color appTextSecondary;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
                  '$itemCount items ready for checkout',
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
              child: Icon(
                Icons.shopping_bag,
                size: 20,
                color: appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final void Function(int delta) onUpdate;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    required this.onUpdate,
  });

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
                src: item.productImageUrl,
                fit: BoxFit.cover,
                cacheWidth: 288,
                cacheHeight: 288,
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
                        item.productTitle,
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
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: appTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${_formatPrice(item.productPrice)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: appTextPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: appBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _QtyButton(icon: Icons.remove, onTap: () => onUpdate(-1)),
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
                      _QtyButton(icon: Icons.add, onTap: () => onUpdate(1)),
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
        child: Center(child: Icon(icon, size: 14, color: appTextSecondary)),
      ),
    );
  }
}

String _formatPrice(int value) {
  final str = value.toString();
  final reg = RegExp(r'\B(?=(\d{3})+(?!\d))');
  return str.replaceAllMapped(reg, (match) => ',');
}
