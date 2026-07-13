import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum BadgeTone { info, success, warn, neutral }

/// Small pill badge: colored background + colored text, matches reference.
class SemanticBadge extends StatelessWidget {
  final String label;
  final BadgeTone tone;

  const SemanticBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.info,
  });

  ({Color bg, Color fg}) get _colors => switch (tone) {
    BadgeTone.info => (bg: AppColors.badgeInfoBg, fg: AppColors.badgeInfoText),
    BadgeTone.success => (
      bg: AppColors.badgeSuccessBg,
      fg: AppColors.badgeSuccessText,
    ),
    BadgeTone.warn => (bg: AppColors.badgeWarnBg, fg: AppColors.badgeWarnText),
    BadgeTone.neutral => (
      bg: AppColors.surfaceMuted,
      fg: AppColors.textSecondary,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: AppType.caption.copyWith(
          color: c.fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
