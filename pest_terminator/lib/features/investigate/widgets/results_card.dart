import 'package:flutter/material.dart';
import 'package:pest_terminator/core/theme/app_colors.dart';
import 'package:pest_terminator/core/theme/app_sizes.dart';
import 'package:pest_terminator/core/widgets/display_widgets.dart';
import 'package:pest_terminator/features/reports/widgets/alert_style.dart';
import '../../reports/models/pest_alert.dart';

// Prelim signals table from wireframe
class ResultsCard extends StatelessWidget {
  const ResultsCard({super.key, required this.rows, this.note});

  // Prediction results
  final List<AnalysisResult> rows;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [

          // Iterate through results
          for(var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 15
              ),

              // Analysis row details (label + value)
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(rows[i].label, style: text.bodyMedium?.copyWith(fontSize: 14)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.end,
                      style: text.bodyMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: rows[i].level?.color ?? AppColors.textPrimary
                      ),
                    )
                  )
                ],
              ),

            ),
            // Divider
            if(i < rows.length - 1 || note != null) 
              const Divider(height: 1, color: AppColors.border),
          ],

          // Note footer (in case we want to highlight notes to guide user) - Last row
          if(note != null)
            Container(
              width: double.infinity,
              color: AppColors.warningSoft,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 14
              ),
              child: IconLabel(
                icon: Icons.notifications_none_rounded, 
                text: note!,
                color: AppColors.textSecondary,
              ),
            )
        ],
      )
    );
  }
}