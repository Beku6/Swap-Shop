import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/publish_job_provider.dart';

class PublishJobBanner extends ConsumerWidget {
  const PublishJobBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(
      publishJobProvider.select(
        (value) => _BannerStateView(
          isVisible: value.shouldShowBanner,
          status: value.status,
          progress: value.progress,
          percent: value.percentInt,
          listingTitle: value.listingTitle,
          error: value.error,
          canRetry: value.canRetry,
          isActive: value.isActive,
          thumbnailPath: value.thumbnailPath,
        ),
      ),
    );
    final notifier = ref.read(publishJobProvider.notifier);

    final title = state.listingTitle.trim().isEmpty
        ? 'New listing'
        : state.listingTitle;
    final statusText = switch (state.status) {
      PublishJobStatus.preparing => 'Preparing...',
      PublishJobStatus.uploading => 'Uploading photos...',
      PublishJobStatus.saving => 'Saving listing...',
      PublishJobStatus.success => 'Published successfully',
      PublishJobStatus.error => 'Upload failed',
      PublishJobStatus.idle => '',
    };

    return RepaintBoundary(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        reverseDuration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeOutCubic,
        transitionBuilder: (child, animation) {
          final slide =
              Tween<Offset>(
                begin: const Offset(0, -0.08),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              );
          return ClipRect(
            child: SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slide, child: child),
              ),
            ),
          );
        },
        child: state.isVisible
            ? Padding(
                key: const ValueKey<String>('publish-banner-visible'),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.4),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _BannerThumbnail(path: state.thumbnailPath),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        statusText,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withValues(
                                            alpha: 0.7,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '${state.percent}%',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white.withValues(
                                          alpha: 0.82,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Icon(
                                      _statusIcon(state.status),
                                      size: 14,
                                      color: Colors.white.withValues(
                                        alpha: 0.72,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: SizedBox(
                                height: 3,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    return Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ColoredBox(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                              milliseconds: 250,
                                            ),
                                            curve: Curves.easeInOut,
                                            width:
                                                constraints.maxWidth *
                                                (state.progress.clamp(0, 1)),
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Color(0xFF4B9BFF),
                                                  Color(0xFF5BD3FF),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (state.status == PublishJobStatus.error)
                              Align(
                                alignment: Alignment.centerRight,
                                child: Wrap(
                                  spacing: 0,
                                  children: [
                                    if (state.canRetry)
                                      _InlineActionText(
                                        label: 'Retry',
                                        onTap: notifier.retry,
                                      ),
                                    if (state.canRetry)
                                      Text(
                                        '·',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                            alpha: 0.55,
                                          ),
                                        ),
                                      ),
                                    _InlineActionText(
                                      label: 'Details',
                                      onTap: () => _showDetailsSheet(
                                        context: context,
                                        message: state.error ?? 'Upload failed',
                                      ),
                                    ),
                                    Text(
                                      '·',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.55,
                                        ),
                                      ),
                                    ),
                                    _InlineActionText(
                                      label: 'Dismiss',
                                      onTap: notifier.reset,
                                    ),
                                  ],
                                ),
                              )
                            else if (state.isActive)
                              Align(
                                alignment: Alignment.centerRight,
                                child: _InlineActionText(
                                  label: 'Hide',
                                  onTap: notifier.hideBanner,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox(key: ValueKey<String>('publish-banner-hidden')),
      ),
    );
  }

  IconData _statusIcon(PublishJobStatus status) {
    return switch (status) {
      PublishJobStatus.success => Icons.check_rounded,
      PublishJobStatus.error => Icons.error_outline_rounded,
      _ => Icons.cloud_upload_outlined,
    };
  }

  void _showDetailsSheet({
    required BuildContext context,
    required String message,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        final textColor = Colors.white.withValues(alpha: 0.88);
        final secondary = Colors.white.withValues(alpha: 0.72);
        return Container(
          color: const Color(0xFF121416),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upload details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: TextStyle(fontSize: 14, color: secondary, height: 1.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BannerThumbnail extends StatelessWidget {
  const _BannerThumbnail({required this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    final imagePath = path;
    return Container(
      width: 48,
      height: 48,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: imagePath == null || imagePath.isEmpty
          ? Icon(
              Icons.image_outlined,
              size: 20,
              color: Colors.white.withValues(alpha: 0.65),
            )
          : Image.file(
              File(imagePath),
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, _, _) => Icon(
                Icons.image_outlined,
                size: 20,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ),
    );
  }
}

class _InlineActionText extends StatelessWidget {
  const _InlineActionText({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 28),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }
}

class _BannerStateView {
  const _BannerStateView({
    required this.isVisible,
    required this.status,
    required this.progress,
    required this.percent,
    required this.listingTitle,
    required this.error,
    required this.canRetry,
    required this.isActive,
    required this.thumbnailPath,
  });

  final bool isVisible;
  final PublishJobStatus status;
  final double progress;
  final int percent;
  final String listingTitle;
  final String? error;
  final bool canRetry;
  final bool isActive;
  final String? thumbnailPath;
}
