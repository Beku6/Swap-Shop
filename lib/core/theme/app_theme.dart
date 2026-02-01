import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.appBgDark,
    fontFamily: null,
    textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: AppColors.appTextPrimaryDark,
          displayColor: AppColors.appTextPrimaryDark,
        ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.blue500.withValues(alpha: 0.3),
      cursorColor: AppColors.appTextPrimaryDark,
      selectionHandleColor: AppColors.blue500,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.appBgLight,
    fontFamily: null,
    textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.appTextPrimaryLight,
          displayColor: AppColors.appTextPrimaryLight,
        ),
    textSelectionTheme: TextSelectionThemeData(
      selectionColor: AppColors.blue500.withValues(alpha: 0.2),
      cursorColor: AppColors.appTextPrimaryLight,
      selectionHandleColor: AppColors.blue500,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
    ),
  );
}
