import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/widgets/app_pressable.dart';
import '../providers/auth_providers.dart';
import '../utils/auth_error_message.dart';
import '../widgets/auth_ui_kit.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _showPassword = false;
  String? _errorText;
  bool _showMismatch = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _passwordsMatch =>
      _passwordController.text == _confirmPasswordController.text;

  Future<void> _register() async {
    if (_isLoading || _isGoogleLoading) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _errorText = null;
      _showMismatch = !_passwordsMatch;
    });
    if (_showMismatch) {
      return;
    }

    setState(() {
      _isLoading = true;
    });
    try {
      await ref
          .read(registerProvider)
          .call(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            displayName: '',
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

  Future<void> _registerWithGoogle() async {
    if (_isLoading || _isGoogleLoading) {
      return;
    }
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
                      Row(children: [AuthBackButton(onTap: _handleBack)]),
                      const SizedBox(height: 32),
                      const Text(
                        'Create your profile.',
                        style: TextStyle(
                          color: AuthPalette.textPrimary,
                          fontSize: 36,
                          height: 1.12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start buying, selling, and swapping.',
                        style: TextStyle(
                          color: AuthPalette.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AuthGlassContainer(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(32),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
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
                            const SizedBox(height: 16),
                            AuthInputField(
                              label: 'Password',
                              controller: _passwordController,
                              hintText: 'Enter your password',
                              obscureText: !_showPassword,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
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
                            const SizedBox(height: 16),
                            AuthInputField(
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              hintText: 'Repeat password',
                              obscureText: !_showPassword,
                              error: _showMismatch,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _register(),
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
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeInOutCubic,
                              switchOutCurve: Curves.easeInOutCubic,
                              child: !_showMismatch
                                  ? const SizedBox(height: 0)
                                  : Padding(
                                      key: const ValueKey<String>('mismatch'),
                                      padding: const EdgeInsets.only(top: 10),
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.error_outline,
                                            size: 12,
                                            color: AuthPalette.danger,
                                          ),
                                          SizedBox(width: 6),
                                          Flexible(
                                            child: Text(
                                              'Passwords do not match',
                                              style: TextStyle(
                                                color: AuthPalette.danger,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                letterSpacing: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
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
                        label: _isLoading ? 'Creating...' : 'Create Account',
                        loading: _isLoading,
                        onTap: (_isLoading || _isGoogleLoading)
                            ? null
                            : _register,
                      ),
                      const SizedBox(height: 16),
                      AuthActionButton(
                        label: _isGoogleLoading
                            ? 'Connecting...'
                            : 'Sign up with Google',
                        loading: _isGoogleLoading,
                        primary: false,
                        leading: const AuthGoogleMark(),
                        onTap: (_isLoading || _isGoogleLoading)
                            ? null
                            : _registerWithGoogle,
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(
                              color: AuthPalette.textMuted,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: AppPressable(
                                  onTap: () => context.push(Routes.signIn),
                                  child: const Text(
                                    'Log in',
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
