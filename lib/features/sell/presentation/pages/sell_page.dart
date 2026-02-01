import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  String sellMode = 'price';

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

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
                      '0 / 5',
                      style: TextStyle(fontSize: 11, color: appTextSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Container(
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
                            Icon(Icons.photo_camera, size: 24, color: appTextSecondary),
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
                  ),
                ),
                const SizedBox(height: 32),
                _LabeledField(
                  label: 'ITEM TITLE',
                  child: TextField(
                    style: TextStyle(fontSize: 15, color: appTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'e.g. Vintage Leica Camera',
                      hintStyle: TextStyle(color: appTextSecondary, fontSize: 15),
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _LabeledField(
                  label: 'CATEGORY',
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select a category',
                          style: TextStyle(fontSize: 15, color: appTextSecondary),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: appTextSecondary),
                      ],
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
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: appTextPrimary),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          hintStyle: TextStyle(color: appTextSecondary),
                          filled: true,
                          fillColor: appSurface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.fromLTRB(40, 16, 20, 16),
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
                    maxLines: null,
                    minLines: 5,
                    style: TextStyle(fontSize: 15, color: appTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'What kind of items are you looking for in return?',
                      hintStyle: TextStyle(color: appTextSecondary, fontSize: 15),
                      filled: true,
                      fillColor: appSurface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
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
                    children: const [
                      Icon(Icons.add, size: 20, color: AppColors.black),
                      SizedBox(width: 8),
                      Text(
                        'Publish Listing',
                        style: TextStyle(color: AppColors.black, fontWeight: FontWeight.w700),
                      ),
                    ],
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

  const _SegmentButton({required this.active, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active ? appBg : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: active ? appTextPrimary : appTextSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? appTextPrimary : appTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
