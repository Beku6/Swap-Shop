import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_error_mapper.dart';
import '../../../../core/utils/app_error_reporter.dart';
import '../../../../core/widgets/app_delayed_loading.dart';
import '../../../../core/widgets/app_error_state.dart';
import '../../../../core/widgets/app_skeletons.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../../core/widgets/offline_status_banner.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../favorites/presentation/providers/favorites_providers.dart';
import '../../../shared/domain/models/cart_item.dart';
import '../../../shared/domain/models/favorite.dart';
import '../../../product/presentation/pages/product_details_page.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../../../sell/presentation/providers/publish_job_provider.dart';
import '../../../sell/presentation/widgets/publish_job_banner.dart';
import '../../../shared/domain/models/product.dart';
import '../widgets/product_card.dart';
import '../widgets/product_feed_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String selectedCategory = 'All';
  String viewMode = 'explore';
  late final ScrollController _scrollController;

  final List<String> categories = const [
    'All',
    'Electronics',
    'Footwear',
    'Lifestyle',
    'Watches',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = 200.0;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - threshold) {
      ref.read(productFeedControllerProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final currentUser = ref.watch(
      authControllerProvider.select((controller) => controller.user),
    );
    final feedState = ref.watch(productFeedControllerProvider);
    final products = _filterProducts(feedState.items, selectedCategory);
    final isOffline = ref.watch(isOfflineProvider);
    final isPublishBannerVisible = ref.watch(
      publishJobProvider.select((state) => state.shouldShowBanner),
    );
    final currentUserId = currentUser?.id;

    return Stack(
      children: [
        CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.asset(
                                  'assets/images/logo.jpeg',
                                  height: 28,
                                  width: 28,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Swap-Shop',
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.75,
                                  color: appTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  AppColors.blue500,
                                  AppColors.violet500,
                                ],
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
                                  src:
                                      'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
                                  cacheWidth: 120,
                                  cacheHeight: 120,
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
                                style: TextStyle(
                                  color: appTextSecondary,
                                  fontSize: 14,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  hintStyle: TextStyle(
                                    color: appTextSecondary,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 18,
                                    color: appTextSecondary,
                                  ),
                                  prefixIconConstraints: const BoxConstraints(
                                    minWidth: 44,
                                  ),
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
                              onPressed: () =>
                                  context.push(Routes.notifications),
                              icon: Icon(
                                Icons.tune,
                                size: 20,
                                color: appTextSecondary,
                              ),
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
                                      onTap: () =>
                                          context.push(Routes.messages),
                                      child: Icon(
                                        Icons.message_outlined,
                                        size: 20,
                                        color: appTextSecondary,
                                      ),
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
                                      border: Border.all(
                                        color: appBg,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (!isPublishBannerVisible) const SizedBox(height: 24),
                      const PublishJobBanner(),
                      if (isPublishBannerVisible) const SizedBox(height: 12),
                      _ModeSwitcher(
                        value: viewMode,
                        onChanged: (mode) => setState(() => viewMode = mode),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
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
                              behavior: HitTestBehavior.opaque,
                              onTap: () =>
                                  setState(() => selectedCategory = category),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: selectedCategory == category
                                      ? appTextPrimary
                                      : appSurface,
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: selectedCategory == category
                                      ? [
                                          BoxShadow(
                                            color: appTextPrimary.withValues(
                                              alpha: 0.1,
                                            ),
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
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            if (feedState.isLoading && products.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: AppDelayedLoading(
                    key: const ValueKey<String>('feed-loading'),
                    child: _FeedLoadingState(mode: viewMode),
                  ),
                ),
              )
            else if (feedState.error != null)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: AppErrorState(
                    key: const ValueKey<String>('feed-error'),
                    title: 'Unable to load feed',
                    message: AppErrorMapper.map(feedState.error!),
                    onRetry: () =>
                        ref.invalidate(productFeedControllerProvider),
                    onReportIssue: () => AppErrorReporter.report(
                      error: feedState.error!,
                      stackTrace: StackTrace.current,
                      reason: 'home_feed_load_failed',
                    ),
                  ),
                ),
              )
            else if (viewMode == 'explore')
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: LayoutBuilder(
                    key: const ValueKey<String>('explore-grid'),
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
                                  key: ValueKey<String>(
                                    'product-${product.id}',
                                  ),
                                  product: product,
                                  onCartTap: () => _addToCart(product),
                                  onTap: () {
                                    context.push(
                                      Routes.product,
                                      extra: ProductDetailsArgs(
                                        productId: product.id,
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
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = products[index];
                    return _FeedCardItem(
                      key: ValueKey<String>('feed-${product.id}'),
                      product: product,
                      currentUserId: currentUserId,
                      onExchange: () {
                        context.push(
                          Routes.product,
                          extra: ProductDetailsArgs(
                            productId: product.id,
                            product: product,
                            sourceMode: 'feed',
                          ),
                        );
                      },
                      onAddToCart: () => _addToCart(product),
                      onToggleFavorite: () => _toggleFavorite(
                        userId: currentUserId,
                        product: product,
                      ),
                    );
                  }, childCount: products.length),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
        OfflineStatusBanner(visible: isOffline),
      ],
    );
  }

  List<Product> _filterProducts(List<Product> items, String category) {
    if (category == 'All') return items;
    return items.where((product) => product.category == category).toList();
  }

  Future<void> _addToCart(Product product) async {
    final currentUser = ref.read(authControllerProvider).user;
    if (currentUser == null) return;
    await ref
        .read(addToCartProvider)
        .call(
          CartItem(
            id: product.id,
            userId: currentUser.id,
            productId: product.id,
            quantity: 1,
            productTitle: product.title,
            productPrice: product.price,
            productImageUrl: product.imageUrls.isNotEmpty
                ? product.imageUrls.first
                : null,
          ),
        );
  }

  Future<void> _toggleFavorite({
    required String? userId,
    required Product product,
  }) async {
    if (userId == null || userId.isEmpty) return;
    final favoriteIds = ref.read(favoriteIdsProvider(userId));
    if (favoriteIds.contains(product.id)) {
      await ref
          .read(removeFavoriteProvider)
          .call(userId: userId, favoriteId: product.id);
      return;
    }
    await ref
        .read(addFavoriteProvider)
        .call(
          Favorite(
            id: product.id,
            userId: userId,
            productId: product.id,
            createdAt: DateTime.now(),
          ),
        );
  }
}

class _FeedLoadingState extends StatelessWidget {
  const _FeedLoadingState({required this.mode});

  final String mode;

  @override
  Widget build(BuildContext context) {
    if (mode == 'feed') {
      return const Column(children: [FeedItemSkeleton(), FeedItemSkeleton()]);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        final width = constraints.maxWidth;
        final itemWidth = (width - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: List<Widget>.generate(
            4,
            (_) =>
                SizedBox(width: itemWidth, child: const ProductCardSkeleton()),
          ),
        );
      },
    );
  }
}

class _FeedCardItem extends ConsumerWidget {
  const _FeedCardItem({
    super.key,
    required this.product,
    required this.currentUserId,
    required this.onExchange,
    required this.onAddToCart,
    required this.onToggleFavorite,
  });

  final Product product;
  final String? currentUserId;
  final VoidCallback onExchange;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = currentUserId;
    final isFavorite = userId != null && userId.isNotEmpty
        ? ref.watch(
            favoriteIdsProvider(
              userId,
            ).select((ids) => ids.contains(product.id)),
          )
        : false;

    return ProductFeedCard(
      product: product,
      currentUserId: userId,
      isFavorite: isFavorite,
      onExchange: onExchange,
      onAddToCart: onAddToCart,
      onToggleFavorite: onToggleFavorite,
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
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged('explore'),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.grid_view,
                                size: 16,
                                color: value == 'explore'
                                    ? appTextPrimary
                                    : appTextSecondary,
                              ),
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
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onChanged('feed'),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.list,
                                size: 16,
                                color: value == 'feed'
                                    ? appTextPrimary
                                    : appTextSecondary,
                              ),
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
              ),
            ],
          );
        },
      ),
    );
  }
}
