import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../widgets/auth_ui_kit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  static const int _firstStepIndex = 0;
  static const int _securityStepIndex = 1;
  static const int _lastStepIndex = 2;

  int _currentStepIndex = _firstStepIndex;
  bool _forward = true;

  void _setStep(int nextIndex) {
    final boundedIndex = nextIndex.clamp(_firstStepIndex, _lastStepIndex);
    if (_currentStepIndex == boundedIndex) {
      return;
    }
    setState(() {
      _forward = boundedIndex >= _currentStepIndex;
      _currentStepIndex = boundedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeInOutCubic,
                    switchOutCurve: Curves.easeInOutCubic,
                    transitionBuilder: (child, animation) {
                      final begin = _forward
                          ? const Offset(0.06, 0)
                          : const Offset(-0.06, 0);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: begin,
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentStepIndex),
                      child: _buildStepContent(context),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    final steps = <Widget>[
      _WelcomeIntroStep(
        onSkip: () => _setStep(_lastStepIndex),
        onNext: () => _setStep(_securityStepIndex),
      ),
      _WelcomeSecurityStep(
        onBack: () => _setStep(_firstStepIndex),
        onContinue: () => _setStep(_lastStepIndex),
      ),
      _WelcomeStartTradingStep(
        onSkip: () => _setStep(_firstStepIndex),
        onCreateAccount: () => context.push(Routes.register),
        onLogIn: () => context.push(Routes.signIn),
      ),
    ];
    assert(steps.length == _lastStepIndex + 1);
    final safeIndex = _currentStepIndex.clamp(_firstStepIndex, _lastStepIndex);
    return steps[safeIndex];
  }
}

class _WelcomeIntroStep extends StatelessWidget {
  const _WelcomeIntroStep({required this.onSkip, required this.onNext});

  final VoidCallback onSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppPressable(
                  onTap: onSkip,
                  minHitTarget: 44,
                  child: const Text(
                    'SKIP',
                    style: TextStyle(
                      color: AuthPalette.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to\nSwap-Shop.',
              style: TextStyle(
                color: AuthPalette.textPrimary,
                fontSize: 60,
                height: 1.1,
                fontWeight: FontWeight.w700,
                letterSpacing: -1.0,
              ),
            ),
            SizedBox(height: 24),
            _DividerPill(),
            SizedBox(height: 32),
            SizedBox(
              width: 280,
              child: Text(
                'The destination for premium trades and rare finds.',
                style: TextStyle(
                  color: AuthPalette.textSecondary,
                  fontSize: 20,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: Column(
            children: [
              AppPressable(
                onTap: onNext,
                borderRadius: BorderRadius.circular(999),
                child: AuthGlassContainer(
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'NEXT',
                          style: TextStyle(
                            color: AuthPalette.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AuthPalette.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_forward,
                            size: 20,
                            color: AuthPalette.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleIndicator(active: true),
                  SizedBox(width: 12),
                  _CircleIndicator(active: false),
                  SizedBox(width: 12),
                  _CircleIndicator(active: false),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WelcomeSecurityStep extends StatelessWidget {
  const _WelcomeSecurityStep({required this.onBack, required this.onContinue});

  final VoidCallback onBack;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                AuthBackButton(onTap: onBack),
                const SizedBox(width: 12),
                const Expanded(
                  child: Center(
                    child: Text(
                      'SECURITY',
                      style: TextStyle(
                        color: AuthPalette.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 44),
              ],
            ),
          ],
        ),
        Column(
          children: [
            const SizedBox(height: 24),
            AuthGlassContainer(
              borderRadius: const BorderRadius.all(Radius.circular(48)),
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const _SecurityAvatar(),
                  const SizedBox(height: 26),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Expanded(
                        child: Text(
                          'Swap Escrow Protection',
                          style: TextStyle(
                            color: AuthPalette.textSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'SECURED',
                        style: TextStyle(
                          color: AuthPalette.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 8,
                      color: const Color(0x0DFFFFFF),
                      child: const FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: AuthPalette.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 12,
                        color: Color(0x66FFFFFF),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'TRANSACTION MONITORED BY SWAP-SHOP',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0x66FFFFFF),
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Protected.\nSecure. Verified.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AuthPalette.textPrimary,
                fontSize: 36,
                height: 1.15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Every transaction is secured via Swap Escrow. Funds and items stay safe until both sides confirm.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AuthPalette.textSecondary,
                  fontSize: 14,
                  height: 1.55,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: AuthGlassContainer(
            borderRadius: const BorderRadius.all(Radius.circular(40)),
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _BarIndicator(active: false),
                    SizedBox(width: 12),
                    _BarIndicator(active: true),
                    SizedBox(width: 12),
                    _BarIndicator(active: false),
                  ],
                ),
                const SizedBox(height: 24),
                AuthActionButton(
                  label: 'Continue',
                  onTap: onContinue,
                  primary: false,
                  backgroundColor: AuthPalette.primary,
                  textColor: AuthPalette.textPrimary,
                  borderColor: Colors.transparent,
                  trailing: const Icon(
                    Icons.arrow_forward,
                    color: AuthPalette.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'STEP 2 OF 3',
                  style: TextStyle(
                    color: AuthPalette.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _WelcomeStartTradingStep extends StatelessWidget {
  const _WelcomeStartTradingStep({
    required this.onSkip,
    required this.onCreateAccount,
    required this.onLogIn,
  });

  final VoidCallback onSkip;
  final VoidCallback onCreateAccount;
  final VoidCallback onLogIn;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppPressable(
                  onTap: onSkip,
                  minHitTarget: 44,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AuthPalette.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Column(
          children: [
            SizedBox(height: 24),
            _StartTradingHero(),
            SizedBox(height: 24),
            Text(
              'Start trading.',
              style: TextStyle(
                color: AuthPalette.textPrimary,
                fontSize: 36,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.8,
              ),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: 260,
              child: Text(
                'Join the community. List your first item in minutes.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AuthPalette.textSecondary,
                  fontSize: 18,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48),
          child: SizedBox(
            width: screenWidth,
            child: AuthGlassContainer(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(48),
              ),
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 48),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleIndicator(active: false, size: 6),
                      SizedBox(width: 10),
                      _CircleIndicator(active: false, size: 6),
                      SizedBox(width: 10),
                      _BarIndicator(active: true, height: 6, width: 32),
                    ],
                  ),
                  const SizedBox(height: 20),
                  AuthActionButton(
                    label: 'Create Account',
                    onTap: onCreateAccount,
                    primary: true,
                  ),
                  const SizedBox(height: 12),
                  AuthActionButton(
                    label: 'Log In',
                    onTap: onLogIn,
                    primary: false,
                    borderColor: const Color(0x4DFFFFFF),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 128,
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DividerPill extends StatelessWidget {
  const _DividerPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 4,
      decoration: BoxDecoration(
        color: const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _SecurityAvatar extends StatelessWidget {
  const _SecurityAvatar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 96,
              height: 96,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: AuthPalette.primary.withValues(alpha: 0.3),
                ),
              ),
              child: const ClipOval(
                child: Image(
                  image: NetworkImage(
                    'https://picsum.photos/seed/julian/200/200',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AuthPalette.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AuthPalette.background, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.verified,
                  color: AuthPalette.textPrimary,
                  size: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Julian Voss',
          style: TextStyle(
            color: AuthPalette.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'VERIFIED ELITE MEMBER',
          style: TextStyle(
            color: AuthPalette.primary,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.8,
          ),
        ),
      ],
    );
  }
}

class _StartTradingHero extends StatelessWidget {
  const _StartTradingHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AuthPalette.primary.withValues(alpha: 0.2),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          Center(
            child: AuthGlassContainer(
              borderRadius: const BorderRadius.all(Radius.circular(32)),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AuthPalette.textPrimary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.add,
                      size: 32,
                      color: AuthPalette.background,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 140,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 96,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIndicator extends StatelessWidget {
  const _CircleIndicator({required this.active, this.size = 8});

  final bool active;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AuthPalette.textPrimary : const Color(0x33FFFFFF),
      ),
    );
  }
}

class _BarIndicator extends StatelessWidget {
  const _BarIndicator({required this.active, this.height = 4, this.width = 32});

  final bool active;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: active ? AuthPalette.primary : const Color(0x33FFFFFF),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
