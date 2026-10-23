import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

// Rounded surface used by every card in app
class AppCard extends StatelessWidget {
  const AppCard({
    super.key, 
    required this.child, 
    this.padding = EdgeInsets.zero
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border)
      ),
      child: child
    );
  }
}

// Optional section title on left
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key, 
    required this.title, 
    this.trailing
  });

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if(trailing != null) trailing!,
      ],
    );
  }
}

// Colored dot + text ("New", "Monitoring", "Resolved")
class StatusLabel extends StatelessWidget {
  const StatusLabel({
    super.key, 
    required this.text, 
    required this.color
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color
          ),
        )
      ],
    );
  }
}

// Icon + text ("High priority")
class IconLabel extends StatelessWidget {
  const IconLabel({
    super.key,
    required this.icon,
    required this.text,
    this.color = AppColors.textSecondary,
    this.bold = false
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: color),
        const SizedBox(width: 6),
        
        Flexible(
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12.5,
              color: color,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500
            ),
          )
        )
      ],
    );
  }
}

// Small rounded chip ("89% match")
class InfoPill extends StatelessWidget {
  const InfoPill({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.logoTint,
    this.foreground = AppColors.accent,
  });
 
  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
 
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: foreground),
            const SizedBox(width: 5),
          ],
          
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
          ),
        ],
      ),
    );
  }
}
 
// Asset path or shows a tinted placeholder when there is no image or it fails to load.
class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });
 
  final String? src;
  final double? width;
  final double? height;
  final BoxFit fit;
 
  static const Widget _placeholder = ColoredBox(
    color: AppColors.logoTint,
    child: Center(
      child: Icon(Icons.bug_report_outlined, size: 32, color: AppColors.accent),
    ),
  );
 
  @override
  Widget build(BuildContext context) {
    final source = src;
    final Widget image;
 
    if (source == null) {
      image = _placeholder;
    } else {
      image = Image.asset(source, fit: fit, errorBuilder: (c, e, s) => _placeholder);
    }
 
    return SizedBox(width: width, height: height, child: image);
  }
}