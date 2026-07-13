import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class AppNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const AppNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

/// Floating nav — white rounded pill of tabs + a circular FAB whose
/// icon/action changes per page. Fully smooth animations, warm shadows.
class FloatingNavBar extends StatelessWidget {
  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;
  final IconData fabIcon;
  final VoidCallback onFab;
  final String fabTooltip;

  const FloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onSelect,
    required this.fabIcon,
    required this.onFab,
    this.fabTooltip = '',
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Expanded(
              child: _NavPill(items: items, index: index, onSelect: onSelect),
            ),
            const SizedBox(width: 12),
            _NavFab(icon: fabIcon, tooltip: fabTooltip, onTap: onFab),
          ],
        ),
      ),
    );
  }
}

// ═══ NAV PILL ══════════════════════════════════════════════════════
class _NavPill extends StatefulWidget {
  final List<AppNavItem> items;
  final int index;
  final ValueChanged<int> onSelect;

  const _NavPill({
    required this.items,
    required this.index,
    required this.onSelect,
  });

  @override
  State<_NavPill> createState() => _NavPillState();
}

class _NavPillState extends State<_NavPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _animation;
  late double _fromIndex;
  late double _toIndex;

  @override
  void initState() {
    super.initState();
    _fromIndex = widget.index.toDouble();
    _toIndex = widget.index.toDouble();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: 1.0,
    );
    _animation = _buildAnimation();
  }

  @override
  void didUpdateWidget(covariant _NavPill old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index) {
      // Start from the current visual position (handles rapid taps smoothly)
      _fromIndex = _currentIndicatorPos();
      _toIndex = widget.index.toDouble();
      _animation = _buildAnimation();
      _controller.forward(from: 0);
    }
  }

  double _currentIndicatorPos() {
    return _fromIndex + (_toIndex - _fromIndex) * _animation.value;
  }

  Animation<double> _buildAnimation() {
    return CurvedAnimation(
      parent: _controller,
      // Material 3 "emphasized" spring — smooth, slight overshoot feel
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1F3C2814),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0x0A3C2814),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / widget.items.length;
          return Stack(
            children: [
              // ── Smoothly sliding indicator pill ────────────
              AnimatedBuilder(
                animation: _animation,
                builder: (context, _) {
                  final pos = _currentIndicatorPos();
                  return Positioned(
                    left: pos * tabWidth,
                    top: 0,
                    bottom: 0,
                    width: tabWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryFaint,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  );
                },
              ),
              // ── Tabs ──────────────────────────────────────
              Row(
                children: [
                  for (var i = 0; i < widget.items.length; i++)
                    Expanded(
                      child: _NavTab(
                        item: widget.items[i],
                        selected: i == widget.index,
                        onTap: () {
                          if (i == widget.index) return;
                          HapticFeedback.selectionClick();
                          widget.onSelect(i);
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

// ═══ SINGLE TAB ═══════════════════════════════════════════════════
class _NavTab extends StatelessWidget {
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: AppColors.primary.withValues(alpha: 0.08),
          highlightColor: AppColors.primary.withValues(alpha: 0.04),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: selected ? 1 : 0),
            builder: (context, t, _) {
              // Smoothly interpolate color and size together
              final color = Color.lerp(
                AppColors.textTertiary,
                AppColors.primary,
                t,
              )!;
              final scale = 1.0 + (0.08 * t); // Icon "swells" 8%
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: scale,
                    child: Icon(
                      // Icon swap happens at 50% progress for cleanness
                      t > 0.5 ? item.selectedIcon : item.icon,
                      size: 22,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.1,
                      fontWeight: t > 0.5 ? FontWeight.w700 : FontWeight.w500,
                      color: color,
                      letterSpacing: 0.1,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ═══ FAB ═══════════════════════════════════════════════════════════
class _NavFab extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _NavFab({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_NavFab> createState() => _NavFabState();
}

class _NavFabState extends State<_NavFab> with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 220),
      value: 0,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;

    Widget fab = ScaleTransition(
      scale: reduce ? const AlwaysStoppedAnimation(1.0) : _pressScale,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.92),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1F3C2814),
              blurRadius: 20, 
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: const Color(0x0A3C2814),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: ClipOval(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.mediumImpact();
                widget.onTap();
              },
              onTapDown: reduce ? null : (_) => _pressController.forward(),
              onTapUp: reduce ? null : (_) => _pressController.reverse(),
              onTapCancel: reduce ? null : () => _pressController.reverse(),
              splashColor: Colors.white.withValues(alpha: 0.20),
              highlightColor: Colors.white.withValues(alpha: 0.08),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, anim) {
                    return FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.7, end: 1.0).animate(
                          CurvedAnimation(
                            parent: anim,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: Icon(
                    widget.icon,
                    key: ValueKey(widget.icon),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: widget.tooltip.isEmpty ? 'Action' : widget.tooltip,
      child: widget.tooltip.isEmpty
          ? fab
          : Tooltip(message: widget.tooltip, child: fab),
    );
  }
}
