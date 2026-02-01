import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  final String activeTab;
  final VoidCallback? onHome;
  final VoidCallback? onCart;
  final VoidCallback? onSell;
  final VoidCallback? onWallet;
  final VoidCallback? onProfile;

  const BottomNav({
    super.key,
    required this.activeTab,
    this.onHome,
    this.onCart,
    this.onSell,
    this.onWallet,
    this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.appNavBg(context),
              border: Border(
                top: BorderSide(color: AppColors.appBorder(context)),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    label: 'Home',
                    icon: Icons.home,
                    active: activeTab == 'home',
                    onTap: onHome,
                  ),
                  _NavButton(
                    label: 'Cart',
                    icon: Icons.shopping_cart,
                    active: activeTab == 'cart',
                    onTap: onCart,
                  ),
                  _SellButton(
                    active: activeTab == 'sell',
                    onTap: onSell,
                  ),
                  _NavButton(
                    label: 'Wallet',
                    icon: Icons.account_balance_wallet,
                    active: activeTab == 'wallet',
                    onTap: onWallet,
                  ),
                  _NavButton(
                    label: 'Me',
                    icon: Icons.person,
                    active: activeTab == 'profile',
                    onTap: onProfile,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SellButton extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;

  const _SellButton({required this.active, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 4),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: active ? AppColors.appNavActive(context) : AppColors.appSurface(context),
              borderRadius: BorderRadius.circular(999),
              border: active ? null : Border.all(color: AppColors.appBorder(context)),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.appNavActive(context).withValues(alpha: 0.1),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Icon(
              Icons.add,
              size: 30,
              color: active ? AppColors.appBackground(context) : AppColors.appNavInactive(context),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'SELL',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            color: active ? AppColors.appNavActive(context) : AppColors.appNavInactive(context),
          ),
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  const _NavButton({
    required this.label,
    required this.icon,
    required this.active,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.appNavActive(context) : AppColors.appNavInactive(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 22,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Center(child: Icon(icon, size: 22, color: color)),
                  if (active)
                    Positioned(
                      bottom: -6,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 4,
                          height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.appNavActive(context),
                          shape: BoxShape.circle,
                        ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
