import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'network_status_service.dart';

final networkStatusServiceProvider = Provider<NetworkStatusService>((ref) {
  return NetworkStatusService();
});

final networkStatusProvider = StreamProvider<NetworkStatus>((ref) {
  return ref.watch(networkStatusServiceProvider).watch();
});

final isOfflineProvider = Provider<bool>((ref) {
  return ref.watch(networkStatusProvider).maybeWhen(
    data: (status) => status == NetworkStatus.offline,
    orElse: () => false,
  );
});
