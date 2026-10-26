import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

// Page chrome shared by every tab screen: background, safe area, scrolling,
// standard padding and a max width for wide browser windows.
class ScreenLayout extends StatelessWidget {
  const ScreenLayout({super.key, required this.children, this.maxWidth = 480});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false, // bottom navigation bar handles the bottom inset
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                AppSpacing.xl,
              ),
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

// Small grey eyebrow, big title and the notification bell on the right.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.hasUnread = true,
    this.onBellPressed,
  });

  final String eyebrow;
  final String title;
  final bool hasUnread;
  final VoidCallback? onBellPressed;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: text.labelSmall?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              Text(title, style: text.headlineLarge),
            ],
          ),
        ),
        NotificationBell(hasUnread: hasUnread, onPressed: onBellPressed),
      ],
    );
  }
}

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key, this.hasUnread = true, this.onPressed});

  final bool hasUnread;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        children: [
          Positioned.fill(
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onPressed,
                child: const Center(
                  child: Icon(Icons.notifications_none_rounded,
                      size: 24, color: AppColors.textPrimary),
                ),
              ),
            ),
          ),
          if (hasUnread)
            Positioned(
              top: 13,
              right: 14,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}