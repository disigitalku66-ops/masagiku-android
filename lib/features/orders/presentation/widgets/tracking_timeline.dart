/// Tracking Timeline Widget
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../data/models/order_model.dart';

class TrackingTimeline extends StatelessWidget {
  final List<TrackingStep> steps;

  const TrackingTimeline({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Belum ada riwayat pelacakan'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        final isFirst = index == 0;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time Column
            SizedBox(
              width: 50,
              child: Column(
                children: [
                  Text(
                    step.timestamp != null
                        ? DateFormat('HH:mm').format(step.timestamp!)
                        : '-',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    step.timestamp != null
                        ? DateFormat('dd MMM').format(step.timestamp!)
                        : '',
                    style: const TextStyle(
                      color: MasagiColors.textSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Line & Dot Column
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: isFirst
                        ? MasagiColors.primary
                        : MasagiColors.divider,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isFirst ? MasagiColors.primary : Colors.grey[400]!,
                      width: 2,
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 50, // Minimum height for connector
                    color: MasagiColors.divider,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.status,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isFirst
                            ? MasagiColors.textPrimary
                            : MasagiColors.textSecondary,
                      ),
                    ),
                    if (step.note != null && step.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        step.note!,
                        style: const TextStyle(
                          color: MasagiColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
