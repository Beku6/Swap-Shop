import 'package:flutter/material.dart';

/// Color tokens sourced from figma/Design Three Screens/src/styles/globals.css
/// and explicit hex values in the TSX/CSS export.
class AppColors {
  AppColors._();

  // ---- Theme-aware app tokens (globals.css :root + .light) ----
  static const Color appBgDark = Color(0xFF0A0A0B);
  static const Color appSurfaceDark = Color(0xFF161618);
  static const Color appCardDark = Color(0xFF161618);
  static const Color appTextPrimaryDark = Color(0xFFFFFFFF);
  static const Color appTextSecondaryDark = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
  static const Color appBorderDark = Color(0x0DFFFFFF); // rgba(255,255,255,0.05)
  static const Color appNavBgDark = Color(0xCC0A0A0B); // rgba(10,10,11,0.8)
  static const Color appNavActiveDark = Color(0xFFFFFFFF);
  static const Color appNavInactiveDark = Color(0x4DFFFFFF); // rgba(255,255,255,0.3)
  static const Color appAccentDark = Color(0xFF3B82F6);

  static const Color appBgLight = Color(0xFFF8F9FA);
  static const Color appSurfaceLight = Color(0xFFFFFFFF);
  static const Color appCardLight = Color(0xFFFFFFFF);
  static const Color appTextPrimaryLight = Color(0xFF0A0A0B);
  static const Color appTextSecondaryLight = Color(0xFF71717A);
  static const Color appBorderLight = Color(0x0D000000); // rgba(0,0,0,0.05)
  static const Color appNavBgLight = Color(0xCCFFFFFF); // rgba(255,255,255,0.8)
  static const Color appNavActiveLight = Color(0xFF0A0A0B);
  static const Color appNavInactiveLight = Color(0x4D000000); // rgba(0,0,0,0.3)
  static const Color appAccentLight = Color(0xFF3B82F6);

  static bool _isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color appBackground(BuildContext context) => _isDark(context) ? appBgDark : appBgLight;
  static Color appSurface(BuildContext context) => _isDark(context) ? appSurfaceDark : appSurfaceLight;
  static Color appCard(BuildContext context) => _isDark(context) ? appCardDark : appCardLight;
  static Color appTextPrimary(BuildContext context) => _isDark(context) ? appTextPrimaryDark : appTextPrimaryLight;
  static Color appTextSecondary(BuildContext context) => _isDark(context) ? appTextSecondaryDark : appTextSecondaryLight;
  static Color appBorder(BuildContext context) => _isDark(context) ? appBorderDark : appBorderLight;
  static Color appNavBg(BuildContext context) => _isDark(context) ? appNavBgDark : appNavBgLight;
  static Color appNavActive(BuildContext context) => _isDark(context) ? appNavActiveDark : appNavActiveLight;
  static Color appNavInactive(BuildContext context) => _isDark(context) ? appNavInactiveDark : appNavInactiveLight;
  static Color appAccent(BuildContext context) => _isDark(context) ? appAccentDark : appAccentLight;
  static Color appCardAction(BuildContext context) => _isDark(context) ? darkCardAction : appSurfaceLight;

  // ---- globals.css (raw token values) ----
  static const String tokenBackground = '#ffffff';
  static const String tokenForeground = 'oklch(0.145 0 0)';
  static const String tokenCard = '#ffffff';
  static const String tokenCardForeground = 'oklch(0.145 0 0)';
  static const String tokenPopover = 'oklch(1 0 0)';
  static const String tokenPopoverForeground = 'oklch(0.145 0 0)';
  static const String tokenPrimary = '#030213';
  static const String tokenPrimaryForeground = 'oklch(1 0 0)';
  static const String tokenSecondary = 'oklch(0.95 0.0058 264.53)';
  static const String tokenSecondaryForeground = '#030213';
  static const String tokenMuted = '#ececf0';
  static const String tokenMutedForeground = '#717182';
  static const String tokenAccent = '#e9ebef';
  static const String tokenAccentForeground = '#030213';
  static const String tokenDestructive = '#d4183d';
  static const String tokenDestructiveForeground = '#ffffff';
  static const String tokenBorder = 'rgba(0, 0, 0, 0.1)';
  static const String tokenInput = 'transparent';
  static const String tokenInputBackground = '#f3f3f5';
  static const String tokenSwitchBackground = '#cbced4';
  static const String tokenRing = 'oklch(0.708 0 0)';
  static const String tokenChart1 = 'oklch(0.646 0.222 41.116)';
  static const String tokenChart2 = 'oklch(0.6 0.118 184.704)';
  static const String tokenChart3 = 'oklch(0.398 0.07 227.392)';
  static const String tokenChart4 = 'oklch(0.828 0.189 84.429)';
  static const String tokenChart5 = 'oklch(0.769 0.188 70.08)';
  static const String tokenSidebar = 'oklch(0.985 0 0)';
  static const String tokenSidebarForeground = 'oklch(0.145 0 0)';
  static const String tokenSidebarPrimary = '#030213';
  static const String tokenSidebarPrimaryForeground = 'oklch(0.985 0 0)';
  static const String tokenSidebarAccent = 'oklch(0.97 0 0)';
  static const String tokenSidebarAccentForeground = 'oklch(0.205 0 0)';
  static const String tokenSidebarBorder = 'oklch(0.922 0 0)';
  static const String tokenSidebarRing = 'oklch(0.708 0 0)';

  // ---- index.css color tokens (oklch) ----
  static const String tokenBlue500 = 'oklch(0.623 0.214 259.815)';
  static const String tokenBlue400 = 'oklch(0.707 0.165 254.624)';
  static const String tokenBlue200 = 'oklch(0.882 0.059 254.128)';
  static const String tokenViolet500 = 'oklch(0.606 0.25 292.717)';
  static const String tokenViolet400 = 'oklch(0.702 0.183 293.541)';
  static const String tokenEmerald500 = 'oklch(0.696 0.17 162.48)';
  static const String tokenEmerald400 = 'oklch(0.765 0.177 163.223)';
  static const String tokenAmber400 = 'oklch(0.828 0.189 84.429)';
  static const String tokenYellow500 = 'oklch(0.795 0.184 86.047)';
  static const String tokenGray100 = 'oklch(0.967 0.003 264.542)';

  // Dark token values (raw)
  static const String tokenDarkBackground = 'oklch(0.145 0 0)';
  static const String tokenDarkForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkCard = 'oklch(0.145 0 0)';
  static const String tokenDarkCardForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkPopover = 'oklch(0.145 0 0)';
  static const String tokenDarkPopoverForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkPrimary = 'oklch(0.985 0 0)';
  static const String tokenDarkPrimaryForeground = 'oklch(0.205 0 0)';
  static const String tokenDarkSecondary = 'oklch(0.269 0 0)';
  static const String tokenDarkSecondaryForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkMuted = 'oklch(0.269 0 0)';
  static const String tokenDarkMutedForeground = 'oklch(0.708 0 0)';
  static const String tokenDarkAccent = 'oklch(0.269 0 0)';
  static const String tokenDarkAccentForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkDestructive = 'oklch(0.396 0.141 25.723)';
  static const String tokenDarkDestructiveForeground = 'oklch(0.637 0.237 25.331)';
  static const String tokenDarkBorder = 'oklch(0.269 0 0)';
  static const String tokenDarkInput = 'oklch(0.269 0 0)';
  static const String tokenDarkRing = 'oklch(0.439 0 0)';
  static const String tokenDarkChart1 = 'oklch(0.488 0.243 264.376)';
  static const String tokenDarkChart2 = 'oklch(0.696 0.17 162.48)';
  static const String tokenDarkChart3 = 'oklch(0.769 0.188 70.08)';
  static const String tokenDarkChart4 = 'oklch(0.627 0.265 303.9)';
  static const String tokenDarkChart5 = 'oklch(0.645 0.246 16.439)';
  static const String tokenDarkSidebar = 'oklch(0.205 0 0)';
  static const String tokenDarkSidebarForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkSidebarPrimary = 'oklch(0.488 0.243 264.376)';
  static const String tokenDarkSidebarPrimaryForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkSidebarAccent = 'oklch(0.269 0 0)';
  static const String tokenDarkSidebarAccentForeground = 'oklch(0.985 0 0)';
  static const String tokenDarkSidebarBorder = 'oklch(0.269 0 0)';
  static const String tokenDarkSidebarRing = 'oklch(0.439 0 0)';

  // ---- globals.css tokens (hex / rgba translated to Color) ----
  static const Color background = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF030213);
  static const Color muted = Color(0xFFECECF0);
  static const Color mutedForeground = Color(0xFF717182);
  static const Color accent = Color(0xFFE9EBEF);
  static const Color destructive = Color(0xFFD4183D);
  static const Color destructiveForeground = Color(0xFFFFFFFF);
  static const Color border = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color inputBackground = Color(0xFFF3F3F5);
  static const Color switchBackground = Color(0xFFCBCED4);
  static const Color transparent = Colors.transparent;

  // ---- Explicit TSX colors ----
  static const Color darkBackground = Color(0xFF0A0A0B);
  static const Color darkCard = Color(0xFF161618);
  static const Color darkCardHover = Color(0xFF1C1C1E);
  static const Color darkCardAction = Color(0xFF1A1A1C);
  static const Color darkCardElevated = Color(0xFF242426);
  static const Color blue500 = Color(0xFF2B7FFF); // oklch token -> sRGB
  static const Color blue400 = Color(0xFF51A2FF); // oklch token -> sRGB
  static const Color blue200 = Color(0xFFBEDBFF); // oklch token -> sRGB
  static const Color blue700 = Color(0xFF2D5BFF);
  static const Color violet500 = Color(0xFF8E51FF); // oklch token -> sRGB
  static const Color violet400 = Color(0xFFA684FF); // oklch token -> sRGB
  static const Color pink500 = Color(0xFFEC4899);
  static const Color amber400 = Color(0xFFFFB900); // oklch token -> sRGB
  static const Color yellow500 = Color(0xFFF0B100); // oklch token -> sRGB
  static const Color emerald500 = Color(0xFF00BC7D); // oklch token -> sRGB
  static const Color emerald400 = Color(0xFF00D492); // oklch token -> sRGB
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}
