import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline, unknown }

class NetworkStatusService {
  NetworkStatusService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  Stream<NetworkStatus> watch() async* {
    var last = await current();
    yield last;

    await for (final raw in _connectivity.onConnectivityChanged) {
      final next = _fromRaw(raw);
      if (next != last) {
        last = next;
        yield next;
      }
    }
  }

  Future<NetworkStatus> current() async {
    final raw = await _connectivity.checkConnectivity();
    return _fromRaw(raw);
  }

  NetworkStatus _fromRaw(Object raw) {
    if (raw is List<ConnectivityResult>) {
      if (raw.isEmpty) {
        return NetworkStatus.unknown;
      }
      return raw.contains(ConnectivityResult.none)
          ? NetworkStatus.offline
          : NetworkStatus.online;
    }

    if (raw is ConnectivityResult) {
      return raw == ConnectivityResult.none
          ? NetworkStatus.offline
          : NetworkStatus.online;
    }

    return NetworkStatus.unknown;
  }
}
