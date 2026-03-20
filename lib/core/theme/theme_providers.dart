import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'theme_controller.dart';

final themeControllerProvider = ChangeNotifierProvider<ThemeController>((ref) {
  return ThemeController.instance;
});
