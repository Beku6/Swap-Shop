import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'image_with_fallback.dart';

class AppMediaCover extends StatelessWidget {
  const AppMediaCover({
    super.key,
    required this.src,
    this.radius = const BorderRadius.all(Radius.circular(0)),
    this.fit = BoxFit.cover,
    this.enableBlurFallback = true,
    this.cacheWidth,
    this.cacheHeight,
    this.showBottomGradient = false,
    this.bottomGradientOpacity = 0.12,
  });

  final String? src;
  final BorderRadius radius;
  final BoxFit fit;
  final bool enableBlurFallback;
  final int? cacheWidth;
  final int? cacheHeight;
  final bool showBottomGradient;
  final double bottomGradientOpacity;

  @override
  Widget build(BuildContext context) {
    final overlayAlpha = Theme.of(context).brightness == Brightness.dark
        ? 0.14
        : 0.06;
    final shouldBlurFallback =
        enableBlurFallback &&
        (src?.isNotEmpty ?? false) &&
        Theme.of(context).brightness == Brightness.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ratio = MediaQuery.of(context).devicePixelRatio;
        final measuredWidth = constraints.maxWidth.isFinite
            ? math.max(1, (constraints.maxWidth * ratio).round())
            : null;
        final measuredHeight = constraints.maxHeight.isFinite
            ? math.max(1, (constraints.maxHeight * ratio).round())
            : null;
        final resolvedCacheWidth = cacheWidth ?? measuredWidth;
        final resolvedCacheHeight = cacheHeight ?? measuredHeight;

        return ClipRRect(
          borderRadius: radius,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: ColoredBox(color: AppColors.appSurface(context)),
              ),
              if (shouldBlurFallback)
                Positioned.fill(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: ImageWithFallback(
                      src: src,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      cacheWidth: resolvedCacheWidth,
                      cacheHeight: resolvedCacheHeight,
                    ),
                  ),
                ),
              if (shouldBlurFallback)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: overlayAlpha),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ImageWithFallback(
                  src: src,
                  fit: fit,
                  alignment: Alignment.center,
                  cacheWidth: resolvedCacheWidth,
                  cacheHeight: resolvedCacheHeight,
                  fadeInDuration: const Duration(milliseconds: 180),
                  placeholderColor: AppColors.appSurface(context),
                ),
              ),
              if (showBottomGradient)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.black.withValues(alpha: 0),
                            AppColors.black.withValues(
                              alpha: bottomGradientOpacity,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
