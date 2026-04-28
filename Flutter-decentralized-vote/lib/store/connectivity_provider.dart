import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_frontend_vote/core/network/connectivity_service.dart';

enum NetworkQuality {
  good,
  slow,
  offline,
}

class NetworkState {
  final bool isConnected;
  final NetworkQuality quality;

  NetworkState({
    required this.isConnected,
    required this.quality,
  });

  factory NetworkState.initial() => NetworkState(
        isConnected: true,
        quality: NetworkQuality.good,
      );

  NetworkState copyWith({
    bool? isConnected,
    NetworkQuality? quality,
  }) {
    return NetworkState(
      isConnected: isConnected ?? this.isConnected,
      quality: quality ?? this.quality,
    );
  }
}

class ConnectivityNotifier extends StateNotifier<NetworkState> {
  final ConnectivityService _service;

  ConnectivityNotifier(this._service) : super(NetworkState.initial()) {
    _init();
  }

  void _init() {
    _service.onConnectivityChanged.listen((connected) {
      state = state.copyWith(
        isConnected: connected,
        quality: connected ? NetworkQuality.good : NetworkQuality.offline,
      );
    });
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, NetworkState>((ref) {
  return ConnectivityNotifier(ConnectivityService());
});
