import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/image_with_fallback.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String activeTab = 'for-sale';

  final List<_StoreItem> forSale = const [
    _StoreItem(
      id: 'fs1',
      title: 'Vintage Lens',
      price: 450,
      image:
          'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    _StoreItem(
      id: 'fs2',
      title: 'Smart Watch',
      price: 299,
      image:
          'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    _StoreItem(
      id: 'fs3',
      title: 'Mechanical Keyboard',
      price: 150,
      image:
          'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
    ),
    _StoreItem(
      id: 'fs4',
      title: 'Matte Lamp',
      price: 85,
      image:
          'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
    ),
  ];

  final List<_StoreItem> sold = const [
    _StoreItem(
      id: 's1',
      title: 'Analog Camera',
      price: 520,
      image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?auto=format&fit=crop&q=80&w=600',
      isSold: true,
    ),
    _StoreItem(
      id: 's2',
      title: 'Leather Tote',
      price: 180,
      image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&q=80&w=600',
      isSold: true,
    ),
    _StoreItem(
      id: 's3',
      title: 'Studio Chair',
      price: 900,
      image: 'https://images.unsplash.com/photo-1592078615290-033ee584e267?auto=format&fit=crop&q=80&w=600',
      isSold: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);
    final themeController = ThemeController.instance;
    final isDark = themeController.isDark;

    final items = activeTab == 'for-sale' ? forSale : sold;
    return Scaffold(
      backgroundColor: appBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.blue500.withValues(alpha: 0.2),
                                AppColors.violet500.withValues(alpha: 0.2),
                              ],
                            ),
                          ),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: appBg,
                            borderRadius: BorderRadius.circular(29),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: const ImageWithFallback(
                              src: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              children: [
                                Text(
                                  'Felix Anderson',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: appTextPrimary),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.verified, size: 16, color: AppColors.blue500),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Curating minimal artifacts and timeless tech. Verified trader since 2024.',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: appTextSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => themeController.toggle(),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: appSurface,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: appBorder),
                              ),
                              child: Icon(
                                isDark ? Icons.nights_stay : Icons.wb_sunny,
                                size: 18,
                                color: appTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: appSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: appBorder),
                            ),
                            child: Icon(Icons.settings, size: 18, color: appTextSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                    const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: appBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StatColumn(value: '12', label: 'ITEMS'),
                        Container(width: 1, height: 32, color: appBorder),
                        _StatColumn(value: '48', label: 'SOLD'),
                        Container(width: 1, height: 32, color: appBorder),
                        Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  '4.9',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: appTextPrimary),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.star, size: 14, color: AppColors.yellow500),
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
                    const SizedBox(height: 20),
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
                              Text(
                                'Appearance',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: appTextPrimary,
                                ),
                              ),
                              Text(
                                isDark ? 'DARK MODE' : 'LIGHT MODE',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.2,
                                  color: appTextSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => themeController.toggle(),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final highlightWidth = (constraints.maxWidth - 8) / 2;
                                return Container(
                                  height: 48,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: appBg,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: appBorder),
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                        left: isDark ? 4 : 4 + highlightWidth,
                                        top: 4,
                                        child: Container(
                                          width: highlightWidth,
                                          height: 48 - 8,
                                          decoration: BoxDecoration(
                                            color: appSurface,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: appBorder),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.black.withValues(alpha: 0.15),
                                                blurRadius: 12,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.nights_stay, size: 14, color: appTextPrimary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Dark',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: appTextPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Center(
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.wb_sunny, size: 14, color: appTextPrimary),
                                                  const SizedBox(width: 6),
                                                  Text(
                                                    'Light',
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w700,
                                                      color: appTextPrimary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: appSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: appBorder),
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
                                color: appBg,
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
                                        color: activeTab == 'for-sale' ? appTextPrimary : appTextSecondary,
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
                                        color: activeTab == 'sold' ? appTextPrimary : appTextSecondary,
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: items.isEmpty
                  ? Column(
                      children: [
                        const SizedBox(height: 80),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: appTextPrimary.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.grid_view, size: 32, color: appTextSecondary.withValues(alpha: 0.4)),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No items found',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: appTextSecondary,
                          ),
                        ),
                      ],
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _StoreTile(item: items[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: appTextPrimary),
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
  final _StoreItem item;

  const _StoreTile({required this.item});

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
              src: item.image,
              fit: BoxFit.cover,
            ),
          ),
          if (item.price != null)
            Positioned(
              top: 12,
              right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.4),
                      border: Border.all(color: AppColors.white.withValues(alpha: 0.1)),
                    ),
                    child: Text(
                      '\$${item.price}',
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
          if (item.isSold)
            Positioned.fill(
              child: Container(
                color: AppColors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Transform.rotate(
                    angle: -0.2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.white.withValues(alpha: 0.4), width: 2),
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
                  item.title,
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

class _StoreItem {
  final String id;
  final String title;
  final int? price;
  final String image;
  final bool isSold;

  const _StoreItem({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    this.isSold = false,
  });
}
