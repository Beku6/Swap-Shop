import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../widgets/product_card.dart';
import '../widgets/product_feed_card.dart';
import '../../../product/presentation/pages/product_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  String viewMode = 'explore';

  final List<Map<String, dynamic>> products = [
    {
      'id': '1',
      'title': 'iPhone 15 Pro Titanium',
      'price': 999,
      'image':
          'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      'images': [
        'https://images.unsplash.com/photo-1698314439902-70a5966b8cc4?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxpcGhvbmUlMjAxNSUyMHBybyUyMHRpdGFuaXVtJTIwZGFyayUyMGJhY2tncm91bmR8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
        'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwZWxlY3Ryb25pYyUyMHByb2R1Y3QlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080',
      ],
      'canSwap': true,
      'category': 'Electronics',
      'description':
          'The natural titanium finish is breathtaking. Barely used, includes original box and accessories. Looking for a swap with a high-end lens or cash.',
      'seller': {
        'name': 'Sarah J.',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sarah',
        'verified': true
      },
      'timestamp': '1 day ago',
    },
    {
      'id': '2',
      'title': 'Minimalist Dark Sneakers',
      'price': 180,
      'image':
          'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      'images': [
        'https://images.unsplash.com/photo-1763750581767-b367bcd6c117?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2Rlcm4lMjBzbmVha2VycyUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
        'https://images.unsplash.com/photo-1611615107443-0e37489ea4da?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwc25lYWtlciUyMGRhcmslMjBiYWNrZ3JvdW5kfGVufDF8fHx8MTc2OTg1OTk3N3ww&ixlib=rb-4.1.0&q=80&w=1080',
      ],
      'canSwap': false,
      'category': 'Footwear',
      'description':
          'Limited edition matte black finish. Brand new in box. Size 10. Perfect for an understated architectural look.',
      'seller': {
        'name': 'Marcus W.',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Marcus',
        'verified': true
      },
      'timestamp': '3 hours ago',
    },
    {
      'id': '3',
      'title': 'Leica Q3 Camera',
      'price': 5995,
      'image':
          'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
      'images': [
        'https://images.unsplash.com/photo-1755136983366-b958dcd2053e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsZWljYSUyMGNhbWVyYSUyMG1pbmltYWxpc3R8ZW58MXx8fHwxNzY5NzY5MTAxfDA&ixlib=rb-4.1.0&q=80&w=1080',
        'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtaW5pbWFsaXN0JTIwZWxlY3Ryb25pYyUyMHByb2R1Y3QlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080',
      ],
      'canSwap': true,
      'category': 'Lifestyle',
      'description':
          'A masterpiece of optical engineering. Shutter count under 500. Interested in bartering for high-end furniture or rare watches.',
      'seller': {
        'name': 'Elena R.',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Elena',
        'verified': true
      },
      'timestamp': 'Just now',
    },
    {
      'id': '4',
      'title': 'Modern Designer Chair',
      'price': 450,
      'image':
          'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
      'images': [
        'https://images.unsplash.com/photo-1762803733564-fecc7669a91a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxkZXNpZ25lciUyMGNoYWlyJTIwbW9kZXJuJTIwZnVybml0dXJlJTIwZGFya3xlbnwxfHx8fDE3Njk3NjkxMDF8MA&ixlib=rb-4.1.0&q=80&w=1080',
        'https://images.unsplash.com/photo-1769255119622-1bd8e49ff35c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxtaW5pbWFsaXN0JTIwZnVybml0dXJlJTIwY2hhaXIlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080',
      ],
      'canSwap': true,
      'category': 'Electronics',
      'description':
          'Ergonomic excellence meets sculptural beauty. Slight patina on the leather which only adds to its character.',
      'seller': {
        'name': 'Julian B.',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Julian',
        'verified': false
      },
      'timestamp': '2 days ago',
    },
    {
      'id': '5',
      'title': 'Luxury Graphite Watch',
      'price': 12500,
      'image':
          'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
      'images': [
        'https://images.unsplash.com/photo-1594120665604-953402382256?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxsdXh1cnklMjB3YXRjaCUyMG1pbmltYWxpc3QlMjBkYXJrfGVufDF8fHx8MTc2OTc2OTEwMXww&ixlib=rb-4.1.0&q=80&w=1080',
        'https://images.unsplash.com/photo-1769594362058-d561f024a235?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHxtaW5pbWFsaXN0JTIwZWxlY3Ryb25pYyUyMHByb2R1Y3QlMjBkYXJrJTIwYmFja2dyb3VuZHxlbnwxfHx8fDE3Njk4NTk5Nzd8MA&ixlib=rb-4.1.0&q=80&w=1080',
      ],
      'canSwap': true,
      'category': 'Watches',
      'description':
          'Automatic movement with 72-hour power reserve. This watch is a statement of precision. Full set with papers.',
      'seller': {
        'name': 'Sophia L.',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophia',
        'verified': true
      },
      'timestamp': '4 days ago',
    },
  ];

  final List<String> categories = const [
    'All',
    'Electronics',
    'Footwear',
    'Lifestyle',
    'Watches',
  ];

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 16, bottom: 96),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    Text(
                      'Swap-Shop',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.75,
                        color: appTextPrimary,
                      ),
                    ),
                    Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [AppColors.blue500, AppColors.violet500],
                          ),
                        ),
                        padding: const EdgeInsets.all(1),
                        child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: appBg,
                        ),
                          child: const ClipOval(
                            child: ImageWithFallback(
                              src: 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: appSurface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          style: TextStyle(color: appTextPrimary, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: TextStyle(color: appTextSecondary, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            prefixIcon: Icon(Icons.search, size: 18, color: appTextSecondary),
                            prefixIconConstraints: const BoxConstraints(minWidth: 44),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: appSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.tune, size: 20, color: appTextSecondary),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Material(
                              color: appSurface,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () => context.push(Routes.messages),
                                child: Icon(Icons.message_outlined, size: 20, color: appTextSecondary),
                              ),
                            ),
                          ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 10,
                                height: 10,
                              decoration: BoxDecoration(
                                color: AppColors.blue500,
                                shape: BoxShape.circle,
                                border: Border.all(color: appBg, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ModeSwitcher(
                    value: viewMode,
                    onChanged: (mode) => setState(() => viewMode = mode),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: GestureDetector(
                          onTap: () => setState(() => selectedCategory = category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: selectedCategory == category ? appTextPrimary : appSurface,
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: selectedCategory == category
                                  ? [
                                      BoxShadow(
                                        color: appTextPrimary.withValues(alpha: 0.1),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selectedCategory == category
                                    ? appBg
                                    : appTextSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: viewMode == 'explore'
                  ? LayoutBuilder(
                      key: const ValueKey('explore-grid'),
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        const gap = 16.0;
                        final itemWidth = (width - gap) / 2;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: products
                              .map(
                                (product) => SizedBox(
                                  width: itemWidth,
                                  child: ProductCard(
                                    product: product,
                                    onTap: () {
                                      context.push(
                                        Routes.product,
                                        extra: ProductDetailsArgs(
                                          product: product,
                                          sourceMode: 'explore',
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    )
                  : ListView.builder(
                      key: const ValueKey('feed-list'),
                      itemCount: products.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return ProductFeedCard(
                          product: product,
                          onAction: () {
                            context.push(
                              Routes.product,
                              extra: ProductDetailsArgs(
                                product: product,
                                sourceMode: 'feed',
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitcher extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _ModeSwitcher({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return SizedBox(
      height: 44,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final highlightWidth = (constraints.maxWidth - 8) / 2;
          return Stack(
            children: [
              Positioned.fill(
                    child: Container(
                  decoration: BoxDecoration(
                    color: appSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    left: value == 'explore' ? 4 : 4 + highlightWidth,
                    top: 4,
                  child: Container(
                    width: highlightWidth,
                    height: constraints.maxHeight - 8,
                    decoration: BoxDecoration(
                      color: appBg,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged('explore'),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.grid_view,
                                size: 16,
                                color: value == 'explore'
                                    ? appTextPrimary
                                    : appTextSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'EXPLORE',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: value == 'explore'
                                    ? appTextPrimary
                                    : appTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged('feed'),
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.list,
                                size: 16,
                                color: value == 'feed'
                                    ? appTextPrimary
                                    : appTextSecondary),
                            const SizedBox(width: 8),
                            Text(
                              'FEED',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                color: value == 'feed'
                                    ? appTextPrimary
                                    : appTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
