import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AppChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const AppChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.color = AppColors.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: AppMotion.fast,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            // design.md category-chip: white + hairline default;
            // category-tinted wash + 1.5px category border when selected.
            color: selected
                ? color.withValues(alpha: 0.12)
                : canvas.surface,
            borderRadius: BorderRadius.circular(AppRadii.pill),
            border: Border.all(
              color: selected ? color : AppColors.borderSubtle,
              width: selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppType.small.copyWith(
                  color: selected ? color : canvas.onCanvas,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
