import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/display_widgets.dart';
import '../../../core/widgets/primary_button.dart';
import '../models/pest_alert.dart';
import 'alert_style.dart';

// One row of the timeline: date chip + connecting line on the left, card on the right.
class AlertTimelineItem extends StatelessWidget {
  const AlertTimelineItem({
    super.key,
    required this.alert,
    required this.onAction,
    this.isLast = false,
  });

  final PestAlert alert;
  final VoidCallback onAction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 52,
            child: Column(
              children: [
                _DateChip(alert: alert),
                Expanded(
                  child: Center(
                    child: Container(width: 1.5, color: AppColors.border),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md - 4),
              child: AlertCard(alert: alert, onAction: onAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.alert});
  final PestAlert alert;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(alert.day, style: text.titleLarge?.copyWith(fontSize: 18)),
          const SizedBox(height: 2),
          Text(
            alert.monthShort,
            style: text.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: 1,
              color: AppColors.hint,
            ),
          ),
        ],
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  const AlertCard({super.key, required this.alert, required this.onAction});

  final PestAlert alert;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final resolved = alert.status == AlertStatus.resolved;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (alert.hasImage)
            Padding(
              padding: const EdgeInsets.all(9),
              child: _Photo(alert: alert),
            ),
          
          Padding(
            padding: EdgeInsets.fromLTRB(15, alert.hasImage ? 6 : 15, 15, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconLabel(
                      icon: Icons.notifications_none_rounded,
                      text: alert.priority.label,
                      color: alert.priority.color,
                      bold: true,
                    ),
                    const Spacer(),
                    StatusLabel(
                      text: alert.status.label,
                      color: alert.status.color,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(alert.title, style: text.titleLarge?.copyWith(fontSize: 17)),
                const SizedBox(height: 14),
                
                PrimaryButton(
                  label: resolved ? 'View prediction' : 'Predict Pest',
                  leadingIcon: resolved
                      ? Icons.description_outlined
                      : Icons.center_focus_strong_outlined,
                  trailingIcon: Icons.chevron_right_rounded,
                  compact: true,
                  tonal: resolved,
                  onPressed: onAction,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo({required this.alert});
  final PestAlert alert;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AppImage(src: alert.imageSrc, width: double.infinity, height: 104),
    );
  }
}