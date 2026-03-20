import 'package:flutter/material.dart';

class AppSkeletonBlock extends StatelessWidget {
  const AppSkeletonBlock({
    super.key,
    required this.height,
    this.width,
    this.radius = 12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class FeedItemSkeleton extends StatelessWidget {
  const FeedItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBlock(height: 18, width: 180),
          SizedBox(height: 12),
          AppSkeletonBlock(height: 220, radius: 28),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: AppSkeletonBlock(height: 48, radius: 16)),
              SizedBox(width: 12),
              Expanded(child: AppSkeletonBlock(height: 48, radius: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: AppSkeletonBlock(height: 0, radius: 20),
        ),
        SizedBox(height: 12),
        AppSkeletonBlock(height: 12, width: 100),
        SizedBox(height: 8),
        AppSkeletonBlock(height: 14, width: 72),
      ],
    );
  }
}

class ChatListItemSkeleton extends StatelessWidget {
  const ChatListItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          AppSkeletonBlock(height: 56, width: 56, radius: 16),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBlock(height: 14, width: 120),
                SizedBox(height: 8),
                AppSkeletonBlock(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSkeletonBlock(height: 48, width: 48, radius: 16),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSkeletonBlock(height: 14),
                SizedBox(height: 8),
                AppSkeletonBlock(height: 12),
                SizedBox(height: 6),
                AppSkeletonBlock(height: 12, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
