import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_ui_kit.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
      _sent = false;
    });
    try {
      await ref
          .read(sendPasswordResetProvider)
          .call(email: _emailController.text.trim());
      if (!mounted) {
        return;
      }
      setState(() {
        _sent = true;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = authErrorMessage(error);
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.signIn);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return AuthScaffold(
      child: SafeArea(
        top: true,
        bottom: true,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(32, 0, 32, 48 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      AuthBackButton(onTap: _handleBack, glass: true),
                      const SizedBox(height: 48),
                      const Text(
                        'Reset access.',
                        style: TextStyle(
                          color: AuthPalette.textPrimary,
                          fontSize: 36,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(
                        width: 280,
                        child: Text(
                          'Enter your email to receive reset instructions.',
                          style: TextStyle(
                            color: AuthPalette.textSecondary,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text(
                          'EMAIL ADDRESS',
                          style: TextStyle(
                            color: AuthPalette.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AuthGlassContainer(
                        padding: EdgeInsets.zero,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16),
                        ),
                        child: SizedBox(
                          height: 64,
                          child: TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => _submit(),
                            style: const TextStyle(
                              color: AuthPalette.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'lux@swapshop.com',
                              hintStyle: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 18,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 18,
                              ),
                              border: InputBorder.none,
                              suffixIcon: Icon(
                                Icons.mail_outline,
                                color: Color(0x665B13EC),
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeInOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        child: _errorText == null
                            ? const SizedBox.shrink()
                            : AuthErrorBanner(
                                key: ValueKey<String>(_errorText!),
                                message: _errorText!,
                              ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeInOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        child: !_sent
                            ? const SizedBox.shrink()
                            : AuthGlassContainer(
                                key: const ValueKey<String>('sent'),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(14),
                                ),
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Color(0xFF22C55E),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Reset instructions were sent to your email.',
                                        style: TextStyle(
                                          color: Color(0xFF86EFAC),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      const Spacer(),
                      AuthActionButton(
                        label: _isLoading ? 'Sending...' : 'Send Instructions',
                        onTap: _isLoading ? null : _submit,
                        loading: _isLoading,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: AppPressable(
                          onTap: () => context.go(Routes.signIn),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_back,
                                size: 16,
                                color: AuthPalette.textSecondary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Back to Login',
                                style: TextStyle(
                                  color: AuthPalette.textSecondary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
