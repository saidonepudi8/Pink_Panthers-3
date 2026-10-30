import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pest_terminator/core/widgets/primary_button.dart';
import 'package:pest_terminator/features/reports/models/pest_alert.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/display_widgets.dart';
import '../../../core/widgets/screen_layout.dart';
import '../../reports/controllers/alert_controller.dart';
import '../widgets/alerts_summary_card.dart';
import '../widgets/results_card.dart';

// Investigation Screen
class InvestigateScreen extends StatelessWidget {
  const InvestigateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AlertsController>();

    return ScreenLayout(
      children: [
        const ScreenHeader(eyebrow: 'AI PEST ANALYSIS', title: 'Investigate alert'),
        const SizedBox(height: AppSpacing.lg),

        // Observe if results list from model prediction is filled out
        Obx(() {
          final alert = c.selected.value;
          return alert == null
            ? _EmptyState(onTap: c.backToAlerts)
            : _AlertDetails(alert: alert);
        })
      ]
    );
  }
}

// AlertDetails if model results received
class _AlertDetails extends StatelessWidget {
  const _AlertDetails({required this.alert});

  final PestAlert alert;

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AlertsController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pest summary card
        AlertsSummaryCard(alert: alert),

        Obx(() {
          if(c.results.isEmpty) return const SizedBox.shrink();

          // Display populated data
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Analysis Results'),
              const SizedBox(height: 14),
              ResultsCard(rows: c.results.toList()),
            ],
          );
        }),

        const SizedBox(height: AppSpacing.lg),

        // Run Prediction button
        Obx(() => PrimaryButton(
              label: c.results.isEmpty
                  ? 'Run AI investigation'
                  : 'Re-run investigation',
              isLoading: c.isPredicting.value,
              onPressed: c.runPrediction,
            )),
        
        Obx(() {
          final error = c.predError.value;
          if (error == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(top: AppSpacing.sm),
            child: Text(
              error,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          );
        }),

        const SizedBox(height: AppSpacing.sm),
        // Back to Reports page text button
        Center(
          child: TextButton.icon(
            onPressed: c.backToAlerts,
            icon: const Icon(Icons.chevron_left_rounded, size: 22), 
            label: const Text(
              'Back to pest alerts',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
          ),
        )

      ],
    );
  }
}

// EmptyState if retrieving model prediction results
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsetsGeometry.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No pest alert selected', style: text.titleLarge),
          
          // Navigate to Reports page button if empty
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Go to Reports',
            compact: true,
            tonal: true,
            trailingIcon: Icons.chevron_right_rounded, 
            onPressed: onTap
          )
        ],
      )
    );
  }
}