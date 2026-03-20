import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_providers.dart';
import '../../../../core/widgets/app_async_value_builder.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../../../shared/domain/models/product.dart';
import '../providers/profile_providers.dart';
import '../widgets/editable_avatar.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key, this.ownerId});

  final String? ownerId;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String activeTab = 'for-sale';

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appAccent = AppColors.appAccent(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentUser = ref.watch(authControllerProvider).user;
    final resolvedOwnerId = widget.ownerId ?? currentUser?.id ?? '';
    final isOwnProfile =
        currentUser != null && resolvedOwnerId == currentUser.id;

    final profileDataAsync = isOwnProfile && resolvedOwnerId.isNotEmpty
        ? ref.watch(profileUserDataProvider(resolvedOwnerId))
        : const AsyncValue<Map<String, dynamic>?>.data(null);
    final profileData =
        profileDataAsync.valueOrNull ?? const <String, dynamic>{};

    final productsAsync = resolvedOwnerId.isEmpty
        ? const AsyncValue<List<Product>>.data(<Product>[])
        : ref.watch(productsByOwnerProvider(resolvedOwnerId));
    final products = productsAsync.valueOrNull ?? const <Product>[];
    final forSale = products.where((product) => product.isAvailable).toList();
    final sold = products.where((product) => !product.isAvailable).toList();
    final items = activeTab == 'for-sale' ? forSale : sold;

    final displayName = _displayNameFor(
      resolvedOwnerId,
      currentUser?.displayName,
    );
    final customAvatarUrl = profileData['avatarUrl'] as String?;
    final avatarFallback = _avatarFallback(
      resolvedOwnerId,
      currentUser?.photoUrl,
    );
    final bio = (profileData['bio'] as String?)?.trim();
    final bioText = (bio != null && bio.isNotEmpty)
        ? bio
        : 'Curating minimal artifacts and timeless tech.';

    return Scaffold(
      backgroundColor: appBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditableAvatar(
                      userId: resolvedOwnerId,
                      avatarUrl: customAvatarUrl,
                      fallbackUrl: avatarFallback,
                      canEdit: isOwnProfile,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _NameRow(name: displayName),
                          const SizedBox(height: 6),
                          Text(
                            bioText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.4,
                              color: appTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _VerifiedRow(color: appTextSecondary),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 44,
                      child: Column(
                        children: [
                          _ThemeIconButton(isDark: isDark),
                          const SizedBox(height: 8),
                          _HeaderIconButton(
                            icon: Icons.settings,
                            onTap: () => context.push(Routes.settings),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: appBorder),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatColumn(
                      value: forSale.length.toString(),
                      label: 'ITEMS',
                    ),
                    Container(width: 1, height: 32, color: appBorder),
                    _StatColumn(value: sold.length.toString(), label: 'SOLD'),
                    Container(width: 1, height: 32, color: appBorder),
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.yellow500,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'RATING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: appTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: appSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: appBorder),
                  boxShadow: isLight
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      left: activeTab == 'for-sale' ? 4 : null,
                      right: activeTab == 'sold' ? 4 : null,
                      top: 4,
                      bottom: 4,
                      width: (MediaQuery.of(context).size.width - 40 - 8) / 2,
                      child: Container(
                        decoration: BoxDecoration(
                          color: appAccent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: appBorder),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => activeTab = 'for-sale'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'For Sale',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: activeTab == 'for-sale'
                                      ? appTextPrimary
                                      : appTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => activeTab = 'sold'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              alignment: Alignment.center,
                              child: Text(
                                'Sold',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: activeTab == 'sold'
                                      ? appTextPrimary
                                      : appTextSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppAsyncValueBuilder<List<Product>>(
                value: productsAsync,
                onRetry: resolvedOwnerId.isEmpty
                    ? null
                    : () => ref.invalidate(
                        productsByOwnerProvider(resolvedOwnerId),
                      ),
                errorTitle: 'Unable to load profile items',
                loadingBuilder: (context) => const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: ProductCardSkeleton()),
                          SizedBox(width: 12),
                          Expanded(child: ProductCardSkeleton()),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: ProductCardSkeleton()),
                          SizedBox(width: 12),
                          Expanded(child: ProductCardSkeleton()),
                        ],
                      ),
                    ],
                  ),
                ),
                dataBuilder: (_) => items.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight.isFinite
                              ? constraints.maxHeight
                              : MediaQuery.of(context).size.height * 0.4;
                          return SizedBox(
                            height: availableHeight,
                            child: Column(
                              children: [
                                Expanded(
                                  child: LayoutBuilder(
                                    builder: (context, innerConstraints) {
                                      return SingleChildScrollView(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight:
                                                innerConstraints.maxHeight,
                                          ),
                                          child: Center(
                                            child: AppEmptyState(
                                              icon: Icons.storefront_outlined,
                                              title: 'No items yet',
                                              subtitle:
                                                  'Start listing something to swap',
                                              actionLabel: 'Start selling',
                                              onAction: () =>
                                                  context.go(Routes.sell),
                                              enableHaptic: true,
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
                        },
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                        itemCount: items.length,
                        itemBuilder: (context, index) => _StoreTile(
                          product: items[index],
                          isSold: activeTab == 'sold',
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NameRow extends StatelessWidget {
  const _NameRow({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final nameStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: appTextPrimary,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        const badgeEstimatedWidth = 84.0;
        final hasInlineRoom =
            constraints.maxWidth >= (badgeEstimatedWidth + 96);
        final inlineTextMaxWidth =
            (constraints.maxWidth - badgeEstimatedWidth - 8).clamp(
              0.0,
              constraints.maxWidth,
            );
        final lineCount = _calculateLineCount(
          name,
          nameStyle,
          hasInlineRoom ? inlineTextMaxWidth : 0,
        );

        if (lineCount == 1 && hasInlineRoom) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: nameStyle,
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeInOutCubic,
                switchOutCurve: Curves.easeInOutCubic,
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: const _VerifiedBadge(
                  key: ValueKey<bool>(true),
                  filled: true,
                ),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: nameStyle,
            ),
            const SizedBox(height: 4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeInOutCubic,
              switchOutCurve: Curves.easeInOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: const _VerifiedBadge(
                key: ValueKey<bool>(false),
                filled: false,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge({super.key, required this.filled});

  final bool filled;

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.blue500;
    final foreground = filled ? AppColors.white : primary;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: filled ? 4 : 3),
      decoration: BoxDecoration(
        color: filled ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

int _calculateLineCount(String text, TextStyle style, double maxWidth) {
  if (text.isEmpty) {
    return 1;
  }
  if (maxWidth <= 0) {
    return 2;
  }
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    maxLines: 2,
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);

  final lines = painter.computeLineMetrics().length;
  if (painter.didExceedMaxLines) {
    return 2;
  }
  return lines.clamp(1, 2);
}

class _VerifiedRow extends StatelessWidget {
  const _VerifiedRow({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.shield_outlined,
          size: 13,
          color: color.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Verified trader since 2024',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ThemeIconButton extends ConsumerWidget {
  const _ThemeIconButton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _HeaderIconButton(
      onTap: () => ref
          .read(themeControllerProvider)
          .toggle(currentBrightness: Theme.of(context).brightness),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeInOutCubic,
        switchOutCurve: Curves.easeInOutCubic,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: Icon(
          isDark ? Icons.wb_sunny : Icons.nights_stay,
          key: ValueKey<bool>(isDark),
          size: 18,
          color: AppColors.appTextSecondary(context),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({this.icon, this.child, required this.onTap});

  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appBorder = AppColors.appBorder(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final isLight = Theme.of(context).brightness == Brightness.light;

    return AppPressable(
      onTap: onTap,
      haptic: AppPressableHaptic.light,
      minHitTarget: 44,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: appSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: appBorder),
          boxShadow: isLight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: child ?? Icon(icon, size: 18, color: appTextSecondary),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: appTextPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            color: appTextSecondary,
          ),
        ),
      ],
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.product, required this.isSold});

  final Product product;
  final bool isSold;

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appBorder = AppColors.appBorder(context);
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: appBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: ImageWithFallback(
              src: product.imageUrls.isNotEmpty
                  ? product.imageUrls.first
                  : null,
              fit: BoxFit.cover,
              cacheWidth: 640,
              cacheHeight: 640,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.4),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isSold)
            Positioned.fill(
              child: Container(
                color: AppColors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SOLD',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.black.withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

String _displayNameFor(String ownerId, String? fallback) {
  if (ownerId.isEmpty) {
    return fallback ?? 'Felix Anderson';
  }
  return fallback ?? _formatOwnerName(ownerId);
}

String _avatarFallback(String ownerId, String? photoUrl) {
  if (photoUrl != null && photoUrl.isNotEmpty) {
    return photoUrl;
  }
  if (ownerId.isEmpty) {
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix';
  }
  return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$ownerId';
}

String _formatOwnerName(String ownerId) {
  final trimmed = ownerId.length > 6 ? ownerId.substring(0, 6) : ownerId;
  return 'User $trimmed';
}
