import 'package:flutter/material.dart';
import 'package:pest_terminator/core/theme/app_sizes.dart';

import '../../../core/theme/app_colors.dart';
import '../models/pest_alert.dart';

// Top header that shows how many pest alerts were resolved or are being monitored. (Similar to Canvas' assignment tracking summary)
class AlertsStatsBar extends StatelessWidget {
  const AlertsStatsBar({super.key, required this.stats});

  final AlertStats stats;

  @override
  Widget build(BuildContext context) {
    final divider = Container(width: 1, color: Colors.white24);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(AppRadius.button + 4),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Stat(value: stats.total, label: 'Total alerts'),
            divider,
            _Stat(value: stats.active, label: 'Active'),
            divider,
            _Stat(value: stats.resolved, label: 'Resolved'),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$value',
            style: text.titleLarge?.copyWith(
              fontSize: 26,
              color: AppColors.onPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: text.bodyMedium?.copyWith(
              fontSize: 12,
              color: AppColors.onPrimary.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}