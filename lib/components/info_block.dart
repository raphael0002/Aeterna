import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Inset info block: small label above, bold value below. Grouped side-by-side
/// on the boarding-pass ticket in the reference.
class InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final CrossAxisAlignment align;

  const InfoBlock({
    super.key,
    required this.label,
    required this.value,
    this.align = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smd,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: align,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppType.small.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppType.h3.copyWith(
              color: AppColors.textPrimary,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
