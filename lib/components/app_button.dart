import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

/// Reference CTA: full-width pill, price/label left, chevron right, red fill.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = true,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _down = false;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  ({Color bg, Color fg, Color? border}) get _colors => switch (widget.variant) {
    AppButtonVariant.primary => (
      bg: AppColors.primary,
      fg: Colors.white,
      border: null,
    ),
    AppButtonVariant.secondary => (
      bg: AppColors.surface,
      fg: AppColors.textPrimary,
      border: AppColors.borderDefault,
    ),
    AppButtonVariant.ghost => (
      bg: Colors.transparent,
      fg: AppColors.textPrimary,
      border: null,
    ),
    AppButtonVariant.danger => (
      bg: AppColors.danger,
      fg: Colors.white,
      border: null,
    ),
  };

  void _tap() {
    HapticFeedback.lightImpact();
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors;
    final reduce = MediaQuery.of(context).disableAnimations;
    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _down = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _down = false) : null,
        onTapCancel: _enabled ? () => setState(() => _down = false) : null,
        onTap: _enabled ? _tap : null,
        child: AnimatedScale(
          scale: _down && !reduce ? 0.97 : 1.0,
          duration: AppMotion.fast,
          child: Opacity(
            opacity: _enabled ? 1.0 : 0.5,
            child: Container(
              height: 56,
              width: widget.expand ? double.infinity : null,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: c.bg,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: c.border == null ? null : Border.all(color: c.border!),
              ),
              child: Row(
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.loading) ...[
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: c.fg,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.smd),
                  ] else if (widget.icon != null) ...[
                    Icon(widget.icon, size: 20, color: c.fg),
                    const SizedBox(width: AppSpacing.smd),
                  ],
                  Flexible(
                    child: Text(
                      widget.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.button.copyWith(color: c.fg),
                    ),
                  ),
                  if (widget.trailingIcon != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    Icon(widget.trailingIcon, size: 18, color: c.fg),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
