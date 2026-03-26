import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  /// Best-effort check for connectivity (not full "internet reachability").
  Future<bool> isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && !results.contains(ConnectivityResult.none);
  }

  /// Emits `true` when connectivity is available, `false` otherwise.
  Stream<bool> streamNetworkStatus() {
    return _connectivity.onConnectivityChanged
        .map((results) => results.isNotEmpty && !results.contains(ConnectivityResult.none))
        .distinct();
  }
}

