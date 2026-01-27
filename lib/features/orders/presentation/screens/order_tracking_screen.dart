/// Order Tracking Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/order_providers.dart';
import '../widgets/tracking_timeline.dart';

class OrderTrackingScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderTrackingScreen> createState() =>
      _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends ConsumerState<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Assuming orderDetailProvider loads order first, and we can fetch tracking
      // Alternatively, we can use a specific provider for tracking
      // For now, let's trigger loadOrder which might trigger tracking if status is appropriate
      // Or explicitly call loadTracking if the definition supports it

      // Let's use the notifier directly to fetch tracking
      final notifier = ref.read(orderDetailProvider(widget.orderId).notifier);

      // We might need to know the orderGroupId (receipt number) to track properly
      // If loadOrder is called first it populates state.order
      notifier.loadOrder(widget.orderId).then((_) {
        final order = ref.read(orderDetailProvider(widget.orderId)).order;
        if (order != null && order.orderGroupId != null) {
          notifier.loadTracking(order.orderGroupId!);
          // Note: using orderGroupId as tracking ID/receipt for now, adjust if needed
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider(widget.orderId));
    final tracking = state.tracking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lacak Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : tracking == null
          ? const Center(child: Text('Data pelacakan tidak tersedia'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tracking Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MasagiColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: MasagiColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping,
                          color: MasagiColors.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Status Pengiriman',
                                style: TextStyle(
                                  color: MasagiColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tracking.orderStatus.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: MasagiColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Riwayat Perjalanan',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Timeline
                  TrackingTimeline(steps: tracking.steps),
                ],
              ),
            ),
    );
  }
}
