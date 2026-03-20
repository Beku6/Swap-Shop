import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_error_mapper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({super.key});

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _emailPasswordController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  bool _isSavingName = false;
  bool _isSavingEmail = false;
  bool _isChangingPassword = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _emailPasswordController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  void _initControllers({
    required String displayName,
    required String email,
  }) {
    if (_displayNameController.text.isEmpty) {
      _displayNameController.text = displayName;
    }
    if (_emailController.text.isEmpty) {
      _emailController.text = email;
    }
  }

  Future<void> _saveDisplayName() async {
    setState(() {
      _isSavingName = true;
    });
    try {
      await ref
          .read(updateDisplayNameProvider)
          .call(_displayNameController.text.trim());
      _showMessage('Display name updated.');
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId != null) {
        ref.invalidate(settingsProfileProvider(userId));
      }
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingName = false;
        });
      }
    }
  }

  Future<void> _saveEmail() async {
    setState(() {
      _isSavingEmail = true;
    });
    try {
      await ref.read(updateEmailProvider).call(
            email: _emailController.text.trim(),
            currentPassword: _emailPasswordController.text,
          );
      _showMessage('Email updated.');
      _emailPasswordController.clear();
      final userId = ref.read(authControllerProvider).user?.id;
      if (userId != null) {
        ref.invalidate(settingsProfileProvider(userId));
      }
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isSavingEmail = false;
        });
      }
    }
  }

  Future<void> _changePassword() async {
    setState(() {
      _isChangingPassword = true;
    });
    try {
      await ref.read(changePasswordProvider).call(
            currentPassword: _currentPasswordController.text,
            newPassword: _newPasswordController.text,
          );
      _showMessage('Password updated.');
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authControllerProvider).user;
    final userId = user?.id ?? '';
    if (userId.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settingsAsync = ref.watch(settingsProfileProvider(userId));
    return Scaffold(
      appBar: AppBar(title: const Text('Manage account')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppErrorMapper.map(error),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          data: (profile) {
            _initControllers(
              displayName: profile.displayName,
              email: profile.email,
            );
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Display name'),
                        const SizedBox(height: 8),
                        TextField(controller: _displayNameController),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isSavingName ? null : _saveDisplayName,
                          child: _isSavingName
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save name'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Email'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Current password (if required)',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isSavingEmail ? null : _saveEmail,
                          child: _isSavingEmail
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Update email'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Change password'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _currentPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Current password',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'New password',
                          ),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _isChangingPassword
                              ? null
                              : _changePassword,
                          child: _isChangingPassword
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Change password'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
