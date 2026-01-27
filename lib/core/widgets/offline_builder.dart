import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/network_info_service.dart';

class OfflineBuilder extends ConsumerWidget {
  final Widget child;

  const OfflineBuilder({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkService = ref.watch(networkInfoServiceProvider);

    return StreamBuilder<List<ConnectivityResult>>(
      stream: networkService.onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline =
            snapshot.hasData &&
            snapshot.data!.contains(ConnectivityResult.none);

        return Stack(
          children: [
            child,
            if (isOffline)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.redAccent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.wifi_off, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Tidak ada koneksi internet',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
