import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;

  const AppSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppType.h2.copyWith(color: canvas.onCanvas)),
                if (subtitle != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!,
                      style:
                          AppType.small.copyWith(color: canvas.onCanvasMuted)),
                ],
              ],
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
