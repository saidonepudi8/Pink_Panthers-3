import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/display_widgets.dart';
import '../../../core/widgets/screen_layout.dart';
import '../controllers/alert_controller.dart';
import '../widgets/alert_card.dart';
import '../widgets/alerts_stat_bar.dart';

// Reports tab: search, summary counts and detection timeline.
class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AlertsController>();
    final text = Theme.of(context).textTheme;

    return ScreenLayout(
      children: [
        const ScreenHeader(eyebrow: 'DETECTION HISTORY', title: 'Pest alerts'),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (v) => c.query.value = v,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search pest alerts',
                  prefixIcon:
                      Icon(Icons.search_rounded, color: AppColors.hint),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _SquareIconButton(
              icon: Icons.calendar_today_outlined,
              onPressed: () {}, // TODO: date range filter
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Obx(() => AlertsStatsBar(stats: c.stats.value)),
        const SizedBox(height: AppSpacing.xl),
        Obx(() {
          final groups = c.groupedByMonth;
          if (groups.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text('No alerts match your search.',
                    style: text.bodyMedium),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final entry in groups.entries) ...[
                SectionHeader(
                  title: entry.key,
                  trailing: Text(
                    '${entry.value.length} '
                    '${entry.value.length == 1 ? 'detection' : 'detections'}',
                    style: text.bodyMedium?.copyWith(fontSize: 13),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                for (var i = 0; i < entry.value.length; i++)
                  AlertTimelineItem(
                    alert: entry.value[i],
                    isLast: i == entry.value.length - 1,
                    onAction: () => c.investigate(entry.value[i]),
                  ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, size: 22, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}