import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/world_map_backdrop.dart';

class HeroSheetScaffold extends StatelessWidget {
  final Widget hero;
  final Widget sheet;
  final Color heroColor;
  final double heroFraction;
  final List<Widget>? heroActions;
  final Widget? heroLeading;
  final Widget? heroTitle;

  const HeroSheetScaffold({
    super.key,
    required this.hero,
    required this.sheet,
    this.heroColor = AppColors.primary,
    this.heroFraction = 0.38,
    this.heroActions,
    this.heroLeading,
    this.heroTitle,
  });

  @override
  Widget build(BuildContext context) {
    final canvas = CanvasColors.of(context);
    return Scaffold(
      backgroundColor: heroColor,
      body: Column(
        children: [
          // ── Hero zone with world-map backdrop ──────────────────────
          Container(
            color: heroColor,
            child: Stack(
              children: [
                const Positioned.fill(child: WorldMapBackdrop()),
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.page,
                    ),
                    child: Column(
                      children: [
                        if (heroLeading != null ||
                            heroActions != null ||
                            heroTitle != null)
                          SizedBox(
                            height: 44,
                            child: Row(
                              children: [
                                ?heroLeading,
                                Expanded(
                                  child: Center(
                                    child: heroTitle ?? const SizedBox.shrink(),
                                  ),
                                ),
                                ...?heroActions,
                              ],
                            ),
                          ),
                        hero,
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── White sheet with notch + grabber ───────────────────────
          Expanded(
            child: Stack(
              children: [
                ClipPath(
                  clipper: const _SheetTopClipper(),
                  child: Container(color: canvas.surface, child: sheet),
                ),
                Positioned(
                  top: 5,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 38,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadii.pill),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetTopClipper extends CustomClipper<Path> {
  const _SheetTopClipper();

  static const double _radius = 22;
  static const double _notchWidth = 78;
  static const double _notchDepth = 15;
  static const double _slant = 16;
  static const double _corner = 4;

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    const half = _notchWidth / 2;

    final path = Path()
      ..moveTo(0, h)
      ..lineTo(0, _radius)
      ..quadraticBezierTo(0, 0, _radius, 0)
      ..lineTo(cx - half, 0)
      ..lineTo(cx - half + _slant - _corner, _notchDepth - _corner)
      ..quadraticBezierTo(
        cx - half + _slant,
        _notchDepth,
        cx - half + _slant + _corner,
        _notchDepth,
      )
      ..lineTo(cx + half - _slant - _corner, _notchDepth)
      ..quadraticBezierTo(
        cx + half - _slant,
        _notchDepth,
        cx + half - _slant + _corner,
        _notchDepth - _corner,
      )
      ..lineTo(cx + half, 0)
      ..lineTo(w - _radius, 0)
      ..quadraticBezierTo(w, 0, w, _radius)
      ..lineTo(w, h)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> old) => false;
}

class HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  const HeroIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadii.md + 2),
    );
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: 0.18),
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
        ),
      ),
    );
  }
}

class HeroSegmentedControl<T> extends StatelessWidget {
  final List<(T value, String label)> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  const HeroSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final seg in segments)
            _SegItem(
              label: seg.$2,
              selected: seg.$1 == selected,
              onTap: () => onChanged(seg.$1),
            ),
        ],
      ),
    );
  }
}

class _SegItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SegItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        child: Text(
          label,
          style: AppType.small.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primary : Colors.white,
          ),
        ),
      ),
    );
  }
}
