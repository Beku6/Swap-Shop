import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_error_mapper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class NotificationsSettingsPage extends ConsumerStatefulWidget {
  const NotificationsSettingsPage({super.key});

  @override
  ConsumerState<NotificationsSettingsPage> createState() =>
      _NotificationsSettingsPageState();
}

class _NotificationsSettingsPageState
    extends ConsumerState<NotificationsSettingsPage> {
  bool _isUpdating = false;

  Future<void> _setEnabled({
    required bool enabled,
    required String userId,
  }) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      final finalEnabled = await ref
          .read(togglePushNotificationsProvider)
          .call(enabled);
      ref.invalidate(pushPermissionGrantedProvider);
      ref.invalidate(settingsProfileProvider(userId));
      if (enabled && !finalEnabled) {
        _showMessage(
          'Permission denied. Enable notifications from device settings.',
        );
      }
    } catch (error) {
      _showMessage(AppErrorMapper.map(error));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
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
    final userId = ref.watch(authControllerProvider).user?.id ?? '';
    final permissionAsync = ref.watch(pushPermissionGrantedProvider);
    final settingsAsync = userId.isEmpty
        ? const AsyncValue<Never>.loading()
        : ref.watch(settingsProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(AppErrorMapper.map(error)),
          ),
          data: (profile) {
            final granted = permissionAsync.valueOrNull ?? false;
            final enabled = profile.pushEnabled && granted;
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
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Enable push notifications'),
                          subtitle: Text(
                            granted
                                ? 'Push is available for this device'
                                : 'Permission not granted on this device',
                          ),
                          value: enabled,
                          onChanged: _isUpdating
                              ? null
                              : (value) =>
                                    _setEnabled(enabled: value, userId: userId),
                        ),
                        if (!granted) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Turn this on to request permission. If denied, enable notifications from system settings.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
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
