import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../models/pest_alert.dart';

// Maps enum values to labels and colors shown in UI, so model stays free of presentation and both screens read the same mapping.
extension AlertPriorityStyle on AlertPriority {
  String get riskLabel => switch (this) {
        AlertPriority.high => 'High',
        AlertPriority.medium => 'Medium',
        AlertPriority.low => 'Low',
      };

  String get label => '$riskLabel priority';

  Color get color => switch(this) {
    AlertPriority.high => AppColors.warning,
    AlertPriority.medium => AppColors.warningSoft,
    AlertPriority.low => AppColors.textSecondary
  };
}

extension AlertStatusStyle on AlertStatus {
  String get label => switch (this) {
        AlertStatus.newDetection => 'New',
        AlertStatus.monitoring => 'Monitoring',
        AlertStatus.resolved => 'Resolved',
      };

  String get detailLabel => this == AlertStatus.newDetection ? 'New detection' : label;

  Color get color => switch(this) {
    AlertStatus.resolved => AppColors.success,
    AlertStatus.monitoring => AppColors.warningSoft,
    AlertStatus.newDetection => AppColors.warning,
  };
}