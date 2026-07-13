import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool border;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.border = true,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasColors.of(context);
    final reduce = MediaQuery.of(context).disableAnimations;
    final tappable = widget.onTap != null;
    return GestureDetector(
      onTapDown: tappable ? (_) => setState(() => _down = true) : null,
      onTapUp: tappable ? (_) => setState(() => _down = false) : null,
      onTapCancel: tappable ? () => setState(() => _down = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down && !reduce ? 0.98 : 1.0,
        duration: AppMotion.fast,
        child: Container(
          padding: widget.padding ?? const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: canvas.surface,
            borderRadius: BorderRadius.circular(AppRadii.lg),
            border:
                widget.border ? Border.all(color: canvas.borderSubtle) : null,
            boxShadow: AppElevation.level1,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
