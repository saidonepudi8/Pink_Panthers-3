import 'package:flutter/material.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/display_widgets.dart';
import '../../reports/models/pest_alert.dart';

// Pest summary card displayed at top of Investigation Page
class AlertsSummaryCard extends StatelessWidget {
  const AlertsSummaryCard({super.key, required this.alert});

  final PestAlert alert;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return AppCard(
      child: SizedBox(
        height: 164,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pest image
            SizedBox(width: 134, child: AppImage(src: alert.imageSrc)),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  // Alert details
                  children: [
                    Text(
                      alert.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleLarge?.copyWith(fontSize: 19),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Field ${alert.field}',
                      style: text.bodyMedium?.copyWith(fontSize: 12.5),
                    ),
                    const Spacer(),
                    IconLabel(icon: Icons.photo_camera_outlined, text: alert.capturedLabel)
                  ],
                )
              )
            )
          ],
        )
      )
    );
  }
}