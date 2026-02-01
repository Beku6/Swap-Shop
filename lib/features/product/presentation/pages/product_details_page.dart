import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';

class ProductDetailsArgs {
  final Map<String, dynamic> product;
  final String sourceMode;

  ProductDetailsArgs({required this.product, required this.sourceMode});
}

class ProductDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? product;
  final String sourceMode;

  const ProductDetailsPage({super.key, required this.product, required this.sourceMode});

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    final p = product ?? {};
    final isFeedSource = sourceMode == 'feed';
    final price = _formatPrice(p['price']);
    final seller = p['seller'] as Map<String, dynamic>? ?? {};
    final sellerAvatar = seller['avatar'] as String? ?? 'https://api.dicebear.com/7.x/avataaars/svg?seed=${p['id']}';
    final sellerName = seller['name'] as String? ?? 'Seller';
    final sellerVerified = seller['verified'] == true;
    final description = p['description'] as String? ??
        'A pristine example of design excellence. This piece is part of a curated collection, maintained with extreme care and ready for its next home.';

    return Scaffold(
      backgroundColor: appBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ImageWithFallback(
                          src: p['image'] as String?,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                appBg.withValues(alpha: 0.9),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.translate(
                  offset: const Offset(0, -80),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 512),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 160),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  (p['category'] as String? ?? '').toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.2,
                                    color: AppColors.blue500,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 12, color: AppColors.amber400),
                                    const SizedBox(width: 6),
                                    Text(
                                      '4.9 (124)',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: appTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              p['title'] as String? ?? '',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: appTextPrimary,
                                height: 1.2,
                                letterSpacing: -0.75,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: _PriceOption(
                                    title: 'Market Price',
                                    value: '\$$price',
                                    subtitle: 'Instant checkout available',
                                    icon: Icons.shopping_cart,
                                    iconColor: appTextPrimary,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: _PriceOption(
                                    title: 'Barter Exchange',
                                    value: 'Trade',
                                    subtitle: 'Item-for-item swap enabled',
                                    icon: Icons.repeat,
                                    iconColor: AppColors.blue400,
                                    titleColor: AppColors.blue400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.blue500.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.blue500.withValues(alpha: 0.1)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.verified, size: 18, color: AppColors.blue400),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        text: 'Protected by ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.35,
                                          color: AppColors.blue200.withValues(alpha: 0.6),
                                        ),
                                        children: const [
                                          TextSpan(
                                            text: 'Swap Escrow',
                                            style: TextStyle(color: AppColors.blue400, fontWeight: FontWeight.w600),
                                          ),
                                          TextSpan(
                                            text:
                                                '. Funds and items are held securely until both parties confirm delivery.',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: appSurface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: appBorder),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 48,
                                            height: 48,
                                            decoration: BoxDecoration(
                                              color: appTextPrimary.withValues(alpha: 0.05),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: appBorder, width: 2),
                                            ),
                                            clipBehavior: Clip.antiAlias,
                                            child: ImageWithFallback(src: sellerAvatar),
                                          ),
                                          const SizedBox(width: 12),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    sellerName,
                                                    style: TextStyle(
                                                      color: appTextPrimary,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  if (sellerVerified) ...[
                                                    const SizedBox(width: 6),
                                                    const Icon(Icons.verified, size: 14, color: AppColors.blue500),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Member since 2023 • 98% Trust Score',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: appTextSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: Row(
                                          children: const [
                                            Text(
                                              'Profile',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.blue400,
                                              ),
                                            ),
                                            SizedBox(width: 6),
                                            Icon(Icons.arrow_forward, size: 14, color: AppColors.blue400),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isFeedSource) ...[
                                    const SizedBox(height: 16),
                                    Row(
                                      children: const [
                                        Expanded(
                                          child: _StatCard(
                                            value: '48',
                                            label: 'SUCCESSFUL SWAPS',
                                          ),
                                        ),
                                        SizedBox(width: 16),
                                        Expanded(
                                          child: _StatCard(
                                            value: '< 2h',
                                            label: 'AVG. RESPONSE',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Text(
                                  'DETAILS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.55,
                                    color: appTextPrimary.withValues(alpha: 0.9),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: appBorder,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.5,
                                color: appTextSecondary,
                              ),
                            ),
                            if (isFeedSource) ...[
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SpecRow(label: 'Condition', value: 'Like New'),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _SpecRow(label: 'Authenticity', value: 'Verified'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SpecRow(label: 'Original Box', value: 'Yes'),
                                  ),
                                  const SizedBox(width: 32),
                                  Expanded(
                                    child: _SpecRow(label: 'Shipping', value: 'Global'),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.black.withValues(alpha: 0.4),
                            border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.chevron_left, color: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    appBg,
                    appBg.withValues(alpha: 0.0),
                  ],
                ),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Propose Swap',
                        background: appSurface,
                        foreground: appTextPrimary,
                        icon: Icons.repeat,
                        iconColor: AppColors.blue400,
                        borderColor: appBorder,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        label: 'Add to Cart',
                        background: appTextPrimary,
                        foreground: appBg,
                        icon: Icons.shopping_cart,
                        iconColor: appBg,
                        shadow: const BoxShadow(
                          color: Color(0x26FFFFFF),
                          blurRadius: 40,
                          offset: Offset(0, 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceOption extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? titleColor;

  const _PriceOption({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appBorder = AppColors.appBorder(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appBorder),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Opacity(
              opacity: 0.1,
              child: Icon(icon, size: 40, color: iconColor),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.55,
                  color: titleColor ?? appTextSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: appTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: appTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: appTextPrimary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: appTextPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 0.9,
              color: appTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const _SpecRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    return Container(
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: appTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: appTextPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color background;
  final Color foreground;
  final Color? borderColor;
  final BoxShadow? shadow;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.background,
    required this.foreground,
    this.borderColor,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
        boxShadow: shadow != null ? [shadow!] : null,
      ),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
