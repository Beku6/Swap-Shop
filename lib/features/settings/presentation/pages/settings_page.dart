import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/theme/theme_providers.dart';
import '../../../../core/utils/app_error_mapper.dart';
import '../../../../core/widgets/image_with_fallback.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _isLoggingOut = false;
  bool _isTogglingPush = false;
  bool _isTogglingPrivate = false;

  Future<void> _togglePush({
    required bool nextValue,
    required String userId,
  }) async {
    setState(() {
      _isTogglingPush = true;
    });
    try {
      final enabled = await ref
          .read(togglePushNotificationsProvider)
          .call(nextValue);
      if (!mounted) {
        return;
      }
      if (nextValue && !enabled) {
        _showMessage(
          'Notification permission denied. Enable it in device settings.',
        );
      }
      ref.invalidate(settingsProfileProvider(userId));
      ref.invalidate(pushPermissionGrantedProvider);
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingPush = false;
        });
      }
    }
  }

  Future<void> _togglePrivate({
    required bool nextValue,
    required String userId,
  }) async {
    setState(() {
      _isTogglingPrivate = true;
    });
    try {
      await ref.read(setPrivateProfileProvider).call(nextValue);
      ref.invalidate(settingsProfileProvider(userId));
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingPrivate = false;
        });
      }
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await ref.read(themeControllerProvider).setMode(mode);
  }

  Future<void> _logout() async {
    if (_isLoggingOut) {
      return;
    }
    setState(() {
      _isLoggingOut = true;
    });
    try {
      await ref.read(signOutProvider).call();
      if (!mounted) {
        return;
      }
      context.go(Routes.signIn);
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingOut = false;
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
    final themeController = ref.watch(themeControllerProvider);
    final permissionAsync = ref.watch(pushPermissionGrantedProvider);
    final settingsAsync = userId.isEmpty
        ? const AsyncValue<Never>.loading()
        : ref.watch(settingsProfileProvider(userId));

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: userId.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : settingsAsync.when(
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
                  final pushPermissionGranted =
                      permissionAsync.valueOrNull ?? false;
                  final pushEnabled = profile.pushEnabled && pushPermissionGranted;
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Account',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  backgroundImage: null,
                                  child: (profile.avatarUrl == null ||
                                          profile.avatarUrl!.isEmpty)
                                      ? const Icon(Icons.person_outline)
                                      : ClipOval(
                                          child: ImageWithFallback(
                                            src: profile.avatarUrl!,
                                            cacheWidth: 132,
                                            cacheHeight: 132,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        profile.displayName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        profile.email,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _SettingsNavTile(
                              title: 'Manage account',
                              onTap: () => context.push(Routes.settingsAccount),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Push notifications'),
                              subtitle: Text(
                                pushPermissionGranted
                                    ? 'Receive push alerts for messages and swaps'
                                    : 'Permission not granted',
                              ),
                              value: pushEnabled,
                              onChanged: _isTogglingPush
                                  ? null
                                  : (value) => _togglePush(
                                        nextValue: value,
                                        userId: userId,
                                      ),
                            ),
                            _SettingsNavTile(
                              title: 'Notification settings',
                              onTap: () =>
                                  context.push(Routes.settingsNotifications),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              segments: const [
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.system,
                                  label: Text('System'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.light,
                                  label: Text('Light'),
                                ),
                                ButtonSegment<ThemeMode>(
                                  value: ThemeMode.dark,
                                  label: Text('Dark'),
                                ),
                              ],
                              selected: <ThemeMode>{themeController.mode},
                              onSelectionChanged: (selection) {
                                _setThemeMode(selection.first);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          children: [
                            SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Private profile'),
                              subtitle: const Text('Optional privacy mode'),
                              value: profile.isPrivate,
                              onChanged: _isTogglingPrivate
                                  ? null
                                  : (value) => _togglePrivate(
                                        nextValue: value,
                                        userId: userId,
                                      ),
                            ),
                            _SettingsNavTile(
                              title: 'Privacy settings',
                              onTap: () => context.push(Routes.settingsPrivacy),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _SectionCard(
                        child: Column(
                          children: [
                            _SettingsNavTile(
                              title: 'About',
                              onTap: () => context.push(Routes.settingsAbout),
                            ),
                            _SettingsNavTile(
                              title: 'Danger zone',
                              onTap: () =>
                                  context.push(Routes.settingsDangerZone),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _isLoggingOut ? null : _logout,
                        child: _isLoggingOut
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Log out'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: Theme.of(context).brightness == Brightness.light ? 1.5 : 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SettingsNavTile extends StatelessWidget {
  const _SettingsNavTile({required this.title, required this.onTap});

  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
