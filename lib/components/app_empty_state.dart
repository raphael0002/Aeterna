import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'app_button.dart';

class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasColors.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: canvas.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: canvas.onCanvasMuted),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                title,
                style: AppType.h2.copyWith(color: canvas.onCanvas),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                message,
                style: AppType.body.copyWith(color: canvas.onCanvasMuted),
                textAlign: TextAlign.center,
              ),
              if (ctaLabel != null && onCta != null) ...[
                const SizedBox(height: AppSpacing.xl),
                AppButton(label: ctaLabel!, onPressed: onCta, expand: false),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
