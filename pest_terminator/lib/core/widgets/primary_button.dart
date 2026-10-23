import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_sizes.dart';

// Full-width primary deep-green button widget

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.trailingIcon = Icons.arrow_forward_rounded,
    this.leadingIcon,
    this.compact = false,
    this.tonal = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? trailingIcon;
  final IconData? leadingIcon;
  final bool compact;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final bkgd = tonal ? AppColors.logoTint : AppColors.primary;
    final foreground = tonal ? AppColors.primary : AppColors.onPrimary;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
      color: foreground,
      fontSize: compact ? 14 : null,
    );

    return SizedBox(
      width: double.infinity,
      height: compact ? 44 : 56,

      // Button
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bkgd,
          foregroundColor: foreground,
          disabledBackgroundColor: bkgd.withValues(alpha: 0.7),
          disabledForegroundColor: foreground,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
        ),

        // Show loading on button if loading else show label and trailing icon
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: foreground,
                  strokeWidth: 2.4,
                ),
              )
            : Row(
              children: [
                if(leadingIcon != null) ...[
                  Icon(leadingIcon, size: 20),
                  const SizedBox(width: 10)
                ],
                Expanded(child: Text(label, style: textStyle)),

                // Show trailing icon if not null
                if (trailingIcon != null) Icon(trailingIcon, size: compact ? 20 : 22)
              ]
            )
      ),
    );
  }
}