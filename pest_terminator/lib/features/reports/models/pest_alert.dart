enum AlertPriority { high, medium, low }

enum AlertStatus { newDetection, monitoring, resolved }

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

class PestAlert {
  const PestAlert({
    required this.id,
    required this.title,
    required this.field,
    required this.crop,
    required this.priority,
    required this.status,
    required this.detectedAt,
    this.species,
    this.imageSrc,
    this.matchPercent,
  });

  final String id;
  final String title; // "Unknown" at first but will change after model inference
  final String field; // "North Field"
  final String crop; // "Wheat"
  final AlertPriority priority;
  final AlertStatus status;
  final DateTime detectedAt;
  final String? species; // "Rodent"
  final String? imageSrc; // asset path
  final int? matchPercent;

  bool get hasImage => imageSrc != null;

  // ---- display helpers shared by both screens ----
  String get day => detectedAt.day.toString().padLeft(2, '0');
  String get monthShort =>
    _months[detectedAt.month - 1].substring(0, 3).toUpperCase();
  String get monthYear => '${_months[detectedAt.month - 1]} ${detectedAt.year}';
  String get timeLabel =>
    '${detectedAt.hour.toString().padLeft(2, '0')}:${detectedAt.minute.toString().padLeft(2, '0')}';

  String get capturedLabel {
    final now = DateTime.now();
    final isToday = now.year == detectedAt.year &&
      now.month == detectedAt.month &&
      now.day == detectedAt.day;
    if (isToday) return 'Captured today at $timeLabel';
    final month = _months[detectedAt.month - 1].substring(0, 3);
    return 'Captured $month ${detectedAt.day} at $timeLabel';
  }

  String get searchText =>
    '$title $field $crop ${species ?? ''} ${priority.name} ${status.name}'.toLowerCase();
}

// Summary counts. Comes from the API; the sample numbers match the wireframe.
class AlertStats {
  const AlertStats({
    required this.total,
    required this.active,
    required this.resolved,
  });

  final int total;
  final int active;
  final int resolved;
}