import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/network/network_providers.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_error_mapper.dart';
import '../../../../core/utils/app_error_reporter.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../product/domain/exceptions/product_upload_exception.dart';
import '../../../product/domain/services/product_image_upload_rules.dart';
import '../../../product/presentation/providers/product_providers.dart';
import '../providers/publish_job_provider.dart';
import '../../../shared/domain/models/product.dart';

class SellPage extends ConsumerStatefulWidget {
  const SellPage({super.key});

  @override
  ConsumerState<SellPage> createState() => _SellPageState();
}

class _SellPageState extends ConsumerState<SellPage> {
  static const List<String> _categories = <String>[
    'Electronics',
    'Fashion',
    'Home',
    'Sports',
    'Books',
    'Other',
  ];

  String sellMode = 'price';
  String? _selectedCategory;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _barterController = TextEditingController();
  final List<File> _selectedImages = [];
  String? _coverImageWarning;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _barterController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (!mounted) return;
    if (picked.isEmpty) return;
    final remaining =
        ProductImageUploadRules.maxImages - _selectedImages.length;
    if (remaining <= 0) {
      _showMessage(
        'You can upload up to ${ProductImageUploadRules.maxImages} images.',
      );
      return;
    }
    setState(() {
      final next = picked.take(remaining).map((file) => File(file.path));
      _selectedImages.addAll(next);
    });
    await _evaluateCoverImageWarning();
  }

  Future<void> _publishListing() async {
    final publishState = ref.read(publishJobProvider);
    if (publishState.isActive) return;
    if (ref.read(isOfflineProvider)) {
      ref
          .read(publishJobProvider.notifier)
          .setError(
            'You are offline. Connect to publish your listing.',
            retryAction: _publishListing,
          );
      _showMessage('You\'re offline. Connect to publish your listing.');
      return;
    }
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;

    final title = _titleController.text.trim();
    if (title.isEmpty) return;
    final descriptionInput = _descriptionController.text.trim();
    if (descriptionInput.isNotEmpty && descriptionInput.length < 10) {
      _showMessage('Description must be at least 10 characters.');
      return;
    }
    if (descriptionInput.length > 500) {
      _showMessage('Description must be 500 characters or less.');
      return;
    }
    final category = _selectedCategory;
    if (category == null) {
      _showMessage('Please select a category.');
      return;
    }

    try {
      ProductImageUploadRules.validateImageCount(_selectedImages.length);
    } on ProductUploadException catch (error) {
      _showMessage(error.message);
      return;
    }

    final price = int.tryParse(_priceController.text.replaceAll(',', '')) ?? 0;
    final barterDetails = _barterController.text.trim();
    final descriptionParts = <String>[
      if (descriptionInput.isNotEmpty) descriptionInput,
      if (sellMode == 'barter' && barterDetails.isNotEmpty) barterDetails,
    ];
    final description = descriptionParts.join('\n\n');
    final publishProductId =
        '${user.id}_${DateTime.now().microsecondsSinceEpoch}';
    final product = Product(
      id: publishProductId,
      ownerId: user.id,
      title: title,
      description: description,
      price: price,
      category: category,
      imageUrls: const [],
      createdAt: DateTime.now(),
      likesCount: 0,
      isAvailable: true,
      isForSwap: sellMode == 'barter',
    );

    final images = List<File>.from(_selectedImages);
    final addProduct = ref.read(addProductProvider);
    final publishJob = ref.read(publishJobProvider.notifier);
    Future<void> runPublish() async {
      var movedToSaving = false;
      try {
        await addProduct.call(
          product: product,
          images: images,
          onProgress: (progress) {
            if (progress >= 1 && !movedToSaving) {
              movedToSaving = true;
              publishJob.setSaving();
              return;
            }
            publishJob.setUploading(
              uploadProgress: progress,
              totalImages: images.length,
            );
          },
        );
        if (mounted) {
          setState(() {
            _titleController.clear();
            _descriptionController.clear();
            _priceController.clear();
            _barterController.clear();
            _selectedImages.clear();
            _selectedCategory = null;
            _coverImageWarning = null;
          });
        }
        publishJob.setSuccess();
      } on ProductUploadException catch (error) {
        publishJob.setError(error.message);
      } catch (error, stackTrace) {
        final message = AppErrorMapper.map(error);
        publishJob.setError(message);
        await AppErrorReporter.report(
          error: error,
          stackTrace: stackTrace,
          reason: 'sell_publish_listing_failed',
        );
      }
    }

    publishJob.startPreparingForListing(
      listingTitle: title,
      thumbnailPath: images.isNotEmpty ? images.first.path : null,
      retryAction: runPublish,
    );
    if (!mounted) return;
    context.go(Routes.home);
    await runPublish();
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _evaluateCoverImageWarning() async {
    if (_selectedImages.isEmpty) {
      if (mounted && _coverImageWarning != null) {
        setState(() {
          _coverImageWarning = null;
        });
      }
      return;
    }

    final firstImage = _selectedImages.first;
    String? warning;
    try {
      final bytes = await firstImage.readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) {
        warning = null;
      } else {
        final sample = decoded.width > 64 || decoded.height > 64
            ? img.copyResize(decoded, width: 64)
            : decoded;
        final pixelCount = sample.width * sample.height;
        if (pixelCount > 0) {
          double sum = 0;
          double sumSquares = 0;
          for (var y = 0; y < sample.height; y++) {
            for (var x = 0; x < sample.width; x++) {
              final pixel = sample.getPixel(x, y);
              final luminance =
                  (0.2126 * pixel.r) + (0.7152 * pixel.g) + (0.0722 * pixel.b);
              sum += luminance;
              sumSquares += luminance * luminance;
            }
          }
          final mean = sum / pixelCount;
          final variance = (sumSquares / pixelCount) - (mean * mean);
          if (mean >= 235 || variance <= 140) {
            warning =
                'Tip: Cover image looks very bright or low detail. Consider a clearer photo.';
          }
        }
      }
    } catch (_) {
      warning = null;
    }

    if (!mounted) return;
    if (_coverImageWarning == warning) return;
    setState(() {
      _coverImageWarning = warning;
    });
  }

  Future<void> _pickCategory() async {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appBorder = AppColors.appBorder(context);

    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: SafeArea(
                top: false,
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    20 + MediaQuery.of(sheetContext).viewInsets.bottom,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: appBorder,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final category in _categories)
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 4,
                        ),
                        title: Text(
                          category,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: appTextPrimary,
                          ),
                        ),
                        trailing: _selectedCategory == category
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: AppColors.blue500,
                              )
                            : null,
                        onTap: () => Navigator.of(sheetContext).pop(category),
                      ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selected == null) return;
    setState(() {
      _selectedCategory = selected;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);
    final publishState = ref.watch(publishJobProvider);
    final isPublishing = publishState.isActive;

    final placeholders = (2 - _selectedImages.length).clamp(0, 2);

    return Scaffold(
      backgroundColor: appBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 128),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'List Item',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: appTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create a new listing for the community',
                    style: TextStyle(color: appTextSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PRODUCT PHOTOS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: appTextSecondary,
                      ),
                    ),
                    Text(
                      '${_selectedImages.length} / ${ProductImageUploadRules.maxImages}',
                      style: TextStyle(fontSize: 11, color: appTextSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: appBorder,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_camera,
                                size: 24,
                                color: appTextSecondary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ADD PHOTO',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: appTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final image in _selectedImages) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: appBorder),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.file(image, fit: BoxFit.cover),
                        ),
                      ],
                      for (var i = 0; i < placeholders; i++) ...[
                        const SizedBox(width: 12),
                        Container(
                          width: 128,
                          height: 128,
                          decoration: BoxDecoration(
                            color: appSurface,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: appBorder),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_coverImageWarning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _coverImageWarning!,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: appTextSecondary,
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                _LabeledField(
                  label: 'ITEM TITLE',
                  child: TextField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 15, color: appTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Vintage Leica Camera',
                      hintStyle: TextStyle(
                        color: appTextSecondary,
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'DESCRIPTION',
                  child: TextFormField(
                    controller: _descriptionController,
                    maxLines: null,
                    minLines: 4,
                    maxLength: 500,
                    style: TextStyle(fontSize: 15, color: appTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Describe the item condition and details',
                      hintStyle: TextStyle(
                        color: appTextSecondary,
                        fontSize: 15,
                      ),
                      counterText: '',
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'CATEGORY',
                  child: GestureDetector(
                    onTap: _pickCategory,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: appSurface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedCategory ?? 'Select a category',
                            style: TextStyle(
                              fontSize: 15,
                              color: _selectedCategory == null
                                  ? appTextSecondary
                                  : appTextPrimary,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: appTextSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'EXCHANGE TYPE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.6,
                    color: appTextSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: appSurface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          active: sellMode == 'price',
                          label: 'Fixed Price',
                          icon: Icons.attach_money,
                          onTap: () => setState(() => sellMode = 'price'),
                        ),
                      ),
                      Expanded(
                        child: _SegmentButton(
                          active: sellMode == 'barter',
                          label: 'Barter',
                          icon: Icons.repeat,
                          onTap: () => setState(() => sellMode = 'barter'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (sellMode == 'price')
                  Stack(
                    children: [
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: appTextPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: appTextSecondary),
                          filled: true,
                          fillColor: appSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(
                            40,
                            16,
                            20,
                            16,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        top: 18,
                        child: Text(
                          '\$',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: appTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  TextField(
                    controller: _barterController,
                    maxLines: null,
                    minLines: 5,
                    style: TextStyle(fontSize: 15, color: appTextPrimary),
                    decoration: InputDecoration(
                      hintText:
                          'What kind of items are you looking for in return?',
                      hintStyle: TextStyle(
                        color: appTextSecondary,
                        fontSize: 15,
                      ),
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                AppPressable(
                  onTap: isPublishing ? null : _publishListing,
                  haptic: AppPressableHaptic.medium,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(
                        alpha: isPublishing ? 0.92 : 1,
                      ),
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
                      children: [
                        if (isPublishing) ...[
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Publishing...',
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.black,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Publish Listing',
                            style: TextStyle(
                              color: AppColors.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final appTextSecondary = AppColors.appTextSecondary(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
            color: appTextSecondary,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final bool active;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.active,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? appBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? appTextPrimary : appTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: active ? appTextPrimary : appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
