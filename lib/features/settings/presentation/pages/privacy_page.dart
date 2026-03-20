import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_error_mapper.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';

class PrivacyPage extends ConsumerStatefulWidget {
  const PrivacyPage({super.key});

  @override
  ConsumerState<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends ConsumerState<PrivacyPage> {
  bool _isUpdating = false;

  Future<void> _setPrivate({
    required bool isPrivate,
    required String userId,
  }) async {
    setState(() {
      _isUpdating = true;
    });
    try {
      await ref.read(setPrivateProfileProvider).call(isPrivate);
      ref.invalidate(settingsProfileProvider(userId));
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
    final settingsAsync = userId.isEmpty
        ? const AsyncValue<Never>.loading()
        : ref.watch(settingsProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy')),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(AppErrorMapper.map(error)),
          ),
          data: (profile) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Private profile'),
                      subtitle: const Text(
                        'Optional setting. Visibility behavior is unchanged in this phase.',
                      ),
                      value: profile.isPrivate,
                      onChanged: _isUpdating
                          ? null
                          : (value) =>
                                _setPrivate(isPrivate: value, userId: userId),
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
