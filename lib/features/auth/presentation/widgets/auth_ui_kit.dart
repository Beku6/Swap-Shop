import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/widgets/app_pressable.dart';

class AuthPalette {
  const AuthPalette._();

  static const Color background = Color(0xFF0B0B0D);
  static const Color primary = Color(0xFF5B13EC);
  static const Color glassFill = Color(0x08FFFFFF);
  static const Color glassBorder = Color(0x14FFFFFF);
  static const Color fieldFill = Color(0x0DFFFFFF);
  static const Color fieldBorder = Color(0x1AFFFFFF);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color danger = Color(0xCCEF4444);
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuthPalette.background,
      body: Stack(
        fit: StackFit.expand,
        children: [const _AuthBackdrop(), child],
      ),
    );
  }
}

class AuthGlassContainer extends StatelessWidget {
  const AuthGlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: AuthPalette.glassFill,
            borderRadius: borderRadius,
            border: Border.all(color: AuthPalette.glassBorder),
          ),
          child: child,
        ),
      ),
    );
  }
}

class AuthActionButton extends StatelessWidget {
  const AuthActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.trailing,
    this.leading,
    this.loading = false,
    this.primary = true,
    this.height = 64,
    this.borderRadius = 999,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.textSize = 18,
    this.textWeight = FontWeight.w700,
  });

  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Widget? leading;
  final bool loading;
  final bool primary;
  final double height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double textSize;
  final FontWeight textWeight;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;
    final resolvedTextColor =
        textColor ??
        (primary ? AuthPalette.background : AuthPalette.textPrimary);
    final resolvedBackgroundColor =
        backgroundColor ??
        (primary ? AuthPalette.textPrimary : Colors.transparent);
    final resolvedBorderColor =
        borderColor ?? (primary ? Colors.transparent : AuthPalette.fieldBorder);

    return AppPressable(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(borderRadius),
      haptic: AppPressableHaptic.light,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 160),
        opacity: enabled ? 1 : 0.6,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: resolvedBackgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: resolvedBorderColor),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 10)],
              if (loading) ...[
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      resolvedTextColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: resolvedTextColor,
                    fontSize: textSize,
                    fontWeight: textWeight,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

class AuthInputField extends StatelessWidget {
  const AuthInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.error = false,
    this.textInputAction,
    this.onSubmitted,
    this.borderRadius = 12,
    this.minHeight = 56,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 17,
    ),
    this.inputStyle,
    this.hintStyle,
    this.labelStyle,
  });

  final String label;
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final bool error;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final double borderRadius;
  final double minHeight;
  final EdgeInsets contentPadding;
  final TextStyle? inputStyle;
  final TextStyle? hintStyle;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            label.toUpperCase(),
            style:
                labelStyle ??
                const TextStyle(
                  color: AuthPalette.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
          ),
        ),
        const SizedBox(height: 8),
        DecoratedBox(
          decoration: BoxDecoration(
            color: AuthPalette.fieldFill,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: error ? AuthPalette.danger : AuthPalette.fieldBorder,
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              textInputAction: textInputAction,
              onSubmitted: onSubmitted,
              style:
                  inputStyle ??
                  const TextStyle(
                    color: AuthPalette.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle:
                    hintStyle ??
                    const TextStyle(color: Color(0xFF475569), fontSize: 15),
                contentPadding: contentPadding,
                border: InputBorder.none,
                suffixIcon: suffix,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AuthGlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: const BorderRadius.all(Radius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 16, color: AuthPalette.danger),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AuthPalette.danger,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthBackButton extends StatelessWidget {
  const AuthBackButton({super.key, required this.onTap, this.glass = false});

  final VoidCallback onTap;
  final bool glass;

  @override
  Widget build(BuildContext context) {
    final icon = const Icon(
      Icons.arrow_back,
      color: AuthPalette.textPrimary,
      size: 22,
    );
    if (!glass) {
      return AppPressable(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: SizedBox(width: 44, height: 44, child: Center(child: icon)),
      );
    }
    return AppPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AuthGlassContainer(
        padding: EdgeInsets.zero,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        child: SizedBox(width: 48, height: 48, child: Center(child: icon)),
      ),
    );
  }
}

class AuthGoogleMark extends StatelessWidget {
  const AuthGoogleMark({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            Color(0xFF4285F4),
            Color(0xFF34A853),
            Color(0xFFFBBC05),
            Color(0xFFEA4335),
            Color(0xFF4285F4),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 11,
        height: 11,
        decoration: const BoxDecoration(
          color: AuthPalette.background,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AuthPalette.background),
        Positioned(
          top: -120,
          right: -120,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AuthPalette.primary.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned(
          left: -180,
          top: MediaQuery.of(context).size.height * 0.42,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AuthPalette.primary.withValues(alpha: 0.06),
            ),
          ),
        ),
      ],
    );
  }
}
