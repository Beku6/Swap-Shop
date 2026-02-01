import 'package:flutter/material.dart';
import 'dart:ui';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../data/wallet_design_controller.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final WalletDesignController _designController = WalletDesignController.instance;

  static const String _photoUrl =
      'https://images.unsplash.com/photo-1760224254117-7a40f7f03fe2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhYnN0cmFjdCUyMGRhcmslMjBwcmVtaXVtJTIwdGV4dHVyZSUyMGx1eHVyeXxlbnwxfHx8fDE3Njk4NTcyMzV8MA&ixlib=rb-4.1.0&q=80&w=1080';
  static const String _textureUrl =
      'https://www.transparenttextures.com/patterns/carbon-fibre.png';

  @override
  void initState() {
    super.initState();
    _designController.load();
  }

  @override
  Widget build(BuildContext context) {
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appSurface = AppColors.appSurface(context);
    final appBorder = AppColors.appBorder(context);

    final actions = [
      _WalletAction(icon: Icons.add, label: 'Add', bg: AppColors.blue500.withValues(alpha: 0.1), fg: AppColors.blue400),
      _WalletAction(icon: Icons.arrow_upward, label: 'Send', bg: AppColors.violet500.withValues(alpha: 0.1), fg: AppColors.violet400),
      _WalletAction(icon: Icons.arrow_downward, label: 'Request', bg: AppColors.emerald500.withValues(alpha: 0.1), fg: AppColors.emerald400),
      _WalletAction(icon: Icons.history, label: 'Log', bg: appTextPrimary.withValues(alpha: 0.05), fg: appTextSecondary),
    ];

    final transactions = [
      _TransactionItem(
        title: 'iPhone 15 Pro Max',
        date: 'Just now',
        amount: '-\$1,200.00',
        type: 'Purchase',
        icon: Icons.arrow_upward,
      ),
      _TransactionItem(
        title: 'Barter Swap: Leica Q3',
        date: 'Yesterday',
        amount: 'In Escrow',
        type: 'Swap',
        icon: Icons.repeat,
      ),
      _TransactionItem(
        title: 'Wallet Top-up',
        date: '2 days ago',
        amount: '+\$500.00',
        type: 'Deposit',
        icon: Icons.arrow_downward,
      ),
      _TransactionItem(
        title: 'Sold: Designer Chair',
        date: '4 days ago',
        amount: '+\$450.00',
        type: 'Sale',
        icon: Icons.arrow_downward,
      ),
    ];

    return SingleChildScrollView(
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
            'Wallet',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.75,
              color: appTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Secure assets and transactions',
            style: TextStyle(color: appTextSecondary, fontSize: 14),
          ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _designController,
            builder: (context, _) {
              final design = _designController.current;
              final isLightCard = design.isLight;
              final cardBg = design.id == WalletCardDesign.minimal ? Colors.white : appSurface;
              final textPrimary = isLightCard ? Colors.black : Colors.white;
              final textSecondary = isLightCard
                  ? Colors.black.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.6);

              return Container(
                height: 224,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: cardBg,
                        border: Border.all(color: appBorder),
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    if (design.id == WalletCardDesign.gradient)
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.9,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.blue700, AppColors.violet500, AppColors.pink500],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (design.id == WalletCardDesign.classic)
                      Positioned.fill(
                        child: Container(
                          color: AppColors.appBgDark,
                          child: Opacity(
                            opacity: 0.03,
                            child: Image.network(
                              _textureUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    if (design.id == WalletCardDesign.photo)
                      Positioned.fill(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const ImageWithFallback(src: _photoUrl, fit: BoxFit.cover),
                            Container(color: Colors.black.withValues(alpha: 0.2)),
                          ],
                        ),
                      ),
                    if (design.id == WalletCardDesign.metallic)
                      Positioned.fill(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(color: const Color(0xFF242426)),
                            Opacity(
                              opacity: 0.5,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [Colors.transparent, Color(0x1AFFFFFF), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(32),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.8, -0.8),
                            radius: 0.8,
                            colors: [
                              isLightCard
                                  ? Colors.black.withValues(alpha: 0.05)
                                  : Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 24,
                      right: 24,
                      child: GestureDetector(
                        onTap: () => _showDesignSheet(context),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isLightCard
                                    ? Colors.black.withValues(alpha: 0.05)
                                    : Colors.white.withValues(alpha: 0.1),
                                border: Border.all(
                                  color: isLightCard
                                      ? Colors.black.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.1),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.palette,
                                size: 18,
                                color: isLightCard
                                    ? Colors.black.withValues(alpha: 0.4)
                                    : Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TOTAL BALANCE',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.65,
                                  color: textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '\$14,250.00',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACCOUNT HOLDER',
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 1.0,
                                      color: textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'FELIX ANDERSON',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isLightCard
                                          ? Colors.black.withValues(alpha: 0.6)
                                          : Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 52,
                                height: 32,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 0,
                                      child: _BlurCircle(isLightCard: isLightCard),
                                    ),
                                    Positioned(
                                      left: 16,
                                      child: _BlurCircle(isLightCard: isLightCard),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) => _ActionTile(action: actions[index]),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: appTextPrimary),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View All',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.blue500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: transactions.map((tx) => _TransactionTile(item: tx)).toList(),
          ),
        ],
      ),
    );
  }

  void _showDesignSheet(BuildContext context) {
    final appBg = AppColors.appBackground(context);
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final appBorder = AppColors.appBorder(context);

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: SafeArea(
                  top: false,
                  child: Container(
                    decoration: BoxDecoration(
                      color: appSurface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      border: Border(top: BorderSide(color: appBorder)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, -12),
                        ),
                      ],
                    ),
                    child: AnimatedBuilder(
                      animation: _designController,
                      builder: (context, _) {
                        final selected = _designController.design;
                        return ListView(
                          controller: scrollController,
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 48),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Card Design',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: appTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Choose a style for your wallet',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: appTextSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).maybePop(),
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: appBg,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: appBorder),
                                    ),
                                    child: Icon(Icons.close, size: 20, color: appTextSecondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ...WalletDesignController.designs.map((design) {
                              final isSelected = selected == design.id;
                              return GestureDetector(
                                onTap: () {
                                  _designController.setDesign(design.id);
                                  Navigator.of(context).maybePop();
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: appBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.blue500.withValues(alpha: 0.5)
                                          : appBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          _DesignPreview(design: design, borderColor: appBorder),
                                          const SizedBox(width: 16),
                                          Text(
                                            design.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              color: isSelected ? appTextPrimary : appTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (isSelected)
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: const BoxDecoration(
                                            color: AppColors.blue500,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: AppColors.white,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _BlurCircle extends StatelessWidget {
  final bool isLightCard;

  const _BlurCircle({required this.isLightCard});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isLightCard ? Colors.black.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: isLightCard ? Colors.black.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.3),
            ),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class _DesignPreview extends StatelessWidget {
  final WalletCardDesignOption design;
  final Color borderColor;

  const _DesignPreview({required this.design, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (design.id == WalletCardDesign.gradient)
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.blue700, AppColors.violet500, AppColors.pink500],
                ),
              ),
            ),
          if (design.id == WalletCardDesign.classic)
            Container(
              color: AppColors.appBgDark,
              child: Opacity(
                opacity: 0.03,
                child: Image.network(
                  _WalletPageState._textureUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (design.id == WalletCardDesign.photo)
            const ImageWithFallback(src: _WalletPageState._photoUrl, fit: BoxFit.cover),
          if (design.id == WalletCardDesign.minimal) Container(color: AppColors.white),
          if (design.id == WalletCardDesign.metallic)
            Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFF242426)),
                Opacity(
                  opacity: 0.6,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.transparent, Color(0x1AFFFFFF), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _WalletAction {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  _WalletAction({required this.icon, required this.label, required this.bg, required this.fg});
}

class _ActionTile extends StatelessWidget {
  final _WalletAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final appTextSecondary = AppColors.appTextSecondary(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: action.bg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(action.icon, size: 22, color: action.fg),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          action.label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: appTextSecondary),
        ),
      ],
    );
  }
}

class _TransactionItem {
  final String title;
  final String date;
  final String amount;
  final String type;
  final IconData icon;

  _TransactionItem({required this.title, required this.date, required this.amount, required this.type, required this.icon});
}

class _TransactionTile extends StatelessWidget {
  final _TransactionItem item;

  const _TransactionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final appSurface = AppColors.appSurface(context);
    final appTextPrimary = AppColors.appTextPrimary(context);
    final appTextSecondary = AppColors.appTextSecondary(context);
    final isPositive = item.amount.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: appTextPrimary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, size: 20, color: appTextSecondary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: appTextPrimary.withValues(alpha: 0.9)),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.date} • ${item.type}',
                  style: TextStyle(fontSize: 12, color: appTextSecondary),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.amount,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isPositive ? AppColors.emerald500 : appTextPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Icon(Icons.chevron_right, size: 14, color: appTextSecondary.withValues(alpha: 0.4)),
            ],
          ),
        ],
      ),
    );
  }
}
