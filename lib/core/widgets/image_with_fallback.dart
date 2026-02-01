import 'dart:convert';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ImageWithFallback extends StatelessWidget {
  final String? src;
  final String? alt;
  final BoxFit fit;

  const ImageWithFallback({super.key, this.src, this.alt, this.fit = BoxFit.cover});

  static final Uint8List _errorBytes = base64Decode(
    'PHN2ZyB3aWR0aD0iODgiIGhlaWdodD0iODgiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgc3Ryb2tlPSIjMDAwIiBzdHJva2UtbGluZWpvaW49InJvdW5kIiBvcGFjaXR5PSIuMyIgZmlsbD0ibm9uZSIgc3Ryb2tlLXdpZHRoPSIzLjciPjxyZWN0IHg9IjE2IiB5PSIxNiIgd2lkdGg9IjU2IiBoZWlnaHQ9IjU2IiByeD0iNiIvPjxwYXRoIGQ9Im0xNiA1OCAxNi0xOCAzMiAzMiIvPjxjaXJjbGUgY3g9IjUzIiBjeT0iMzUiIHI9IjciLz48L3N2Zz4KCg==',
  );

  @override
  Widget build(BuildContext context) {
    if (src == null || src!.isEmpty) {
      return _errorWidget();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final pixelRatio = MediaQuery.of(context).devicePixelRatio;
        final hasFiniteWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0;
        final hasFiniteHeight = constraints.maxHeight.isFinite && constraints.maxHeight > 0;
        final cacheWidth = hasFiniteWidth ? (constraints.maxWidth * pixelRatio).round() : null;
        final cacheHeight = hasFiniteHeight ? (constraints.maxHeight * pixelRatio).round() : null;

        return CachedNetworkImage(
          imageUrl: src!,
          fit: fit,
          width: double.infinity,
          height: double.infinity,
          memCacheWidth: cacheWidth,
          memCacheHeight: cacheHeight,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (context, url) => const SizedBox.expand(),
          errorWidget: (context, url, error) => _errorWidget(),
        );
      },
    );
  }

  Widget _errorWidget() {
    return Container(
      color: AppColors.gray100,
      alignment: Alignment.center,
      child: Image.memory(_errorBytes),
    );
  }
}
