import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WalletCardDesign { gradient, classic, photo, minimal, metallic }

class WalletCardDesignOption {
  final WalletCardDesign id;
  final String name;
  final bool isLight;

  const WalletCardDesignOption({
    required this.id,
    required this.name,
    this.isLight = false,
  });
}

class WalletDesignController extends ChangeNotifier {
  WalletDesignController._();

  static final WalletDesignController instance = WalletDesignController._();
  static const String _prefKey = 'wallet_card_design';

  static const List<WalletCardDesignOption> designs = [
    WalletCardDesignOption(id: WalletCardDesign.gradient, name: 'Deep Sea'),
    WalletCardDesignOption(id: WalletCardDesign.classic, name: 'Noir'),
    WalletCardDesignOption(id: WalletCardDesign.photo, name: 'Horizon'),
    WalletCardDesignOption(id: WalletCardDesign.minimal, name: 'Canvas', isLight: true),
    WalletCardDesignOption(id: WalletCardDesign.metallic, name: 'Titanium'),
  ];

  WalletCardDesign _design = WalletCardDesign.gradient;

  WalletCardDesign get design => _design;
  WalletCardDesignOption get current =>
      designs.firstWhere((option) => option.id == _design);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_prefKey);
    _design = _fromString(value) ?? WalletCardDesign.gradient;
    notifyListeners();
  }

  Future<void> setDesign(WalletCardDesign design) async {
    if (_design == design) return;
    _design = design;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, _design.name);
  }

  WalletCardDesign? _fromString(String? value) {
    if (value == null) return null;
    for (final design in WalletCardDesign.values) {
      if (design.name == value) return design;
    }
    return null;
  }
}
