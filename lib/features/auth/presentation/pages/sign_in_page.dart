import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_ui_kit.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _showPassword = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading || _isGoogleLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _errorText = null;
    });
    try {
      await ref
          .read(signInProvider)
          .call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      if (!mounted) {
        return;
      }
      context.go(Routes.home);
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

  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isGoogleLoading = true;
      _errorText = null;
    });
    try {
      await ref.read(signInWithGoogleProvider).call();
      if (!mounted) {
        return;
      }
      context.go(Routes.home);
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
          _isGoogleLoading = false;
        });
      }
    }
  }

  void _handleBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go(Routes.welcome);
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
                      Row(
                        children: [
                          AuthBackButton(onTap: _handleBack),
                          const Expanded(
                            child: Text(
                              'Swap-Shop',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AuthPalette.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      const SizedBox(height: 48),
                      const Text(
                        'Access your account.',
                        style: TextStyle(
                          color: AuthPalette.textPrimary,
                          fontSize: 36,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Continue where you left off.',
                        style: TextStyle(
                          color: AuthPalette.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),
                      AuthGlassContainer(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AuthInputField(
                              label: 'Email',
                              controller: _emailController,
                              hintText: 'name@example.com',
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                            const SizedBox(height: 18),
                            AuthInputField(
                              label: 'Password',
                              controller: _passwordController,
                              hintText: 'Enter your password',
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _signIn(),
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showPassword = !_showPassword;
                                  });
                                },
                                icon: Icon(
                                  _showPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AuthPalette.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: AppPressable(
                                onTap: () =>
                                    context.push(Routes.forgotPassword),
                                child: const Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: AuthPalette.primary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        switchInCurve: Curves.easeInOutCubic,
                        switchOutCurve: Curves.easeInOutCubic,
                        child: _errorText == null
                            ? const SizedBox.shrink()
                            : Padding(
                                key: ValueKey<String>(_errorText!),
                                padding: const EdgeInsets.only(bottom: 2),
                                child: AuthErrorBanner(message: _errorText!),
                              ),
                      ),
                      const Spacer(),
                      AuthActionButton(
                        label: _isLoading ? 'Signing In...' : 'Sign In',
                        loading: _isLoading,
                        onTap: (_isLoading || _isGoogleLoading)
                            ? null
                            : _signIn,
                      ),
                      const SizedBox(height: 16),
                      AuthActionButton(
                        label: _isGoogleLoading
                            ? 'Connecting...'
                            : 'Sign in with Google',
                        loading: _isGoogleLoading,
                        primary: false,
                        leading: const AuthGoogleMark(),
                        onTap: (_isLoading || _isGoogleLoading)
                            ? null
                            : _signInWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: "Don't have an account? ",
                            style: const TextStyle(
                              color: AuthPalette.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: AppPressable(
                                  onTap: () => context.push(Routes.register),
                                  child: const Text(
                                    'Create one',
                                    style: TextStyle(
                                      color: AuthPalette.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
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
