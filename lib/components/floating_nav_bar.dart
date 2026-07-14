// lib/components/floating_nav_bar.dart
import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _tabs = [
    _TabData(
      outline: Amicons.iconly_home_broken,
      filled: Amicons.iconly_home_fill,
      label: 'Home',
    ),
    _TabData(
      outline: Amicons.iconly_search_broken,
      filled: Amicons.iconly_search_fill,
      label: 'Search',
    ),
    _TabData(
      outline: Amicons.iconly_plus_fill,
      filled: Amicons.iconly_plus,
      label: 'Add',
    ),
    _TabData(
      outline: Amicons.iconly_calendar_broken,
      filled: Amicons.iconly_calendar_fill,
      label: 'Calendar',
    ),
    _TabData(
      outline: Amicons.iconly_location_broken,
      filled: Amicons.iconly_location_fill,
      label: 'Map',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        border: Border(top: BorderSide(color: Color(0x14000000), width: 0.5)),
      ),
      child: SizedBox(
        height: 60,
        child: Row(
          children: List.generate(_tabs.length, (i) {
            return Expanded(
              child: _NavTab(
                data: _tabs[i],
                selected: currentIndex == i,
                isCenter: i == 2,
                onTap: () {
                  if (i == 2) {
                    HapticFeedback.mediumImpact();
                  } else {
                    if (currentIndex == i) return;
                    HapticFeedback.selectionClick();
                  }
                  onTap(i);
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabData {
  final IconData outline;
  final IconData filled;
  final String label;
  const _TabData({
    required this.outline,
    required this.filled,
    required this.label,
  });
}

class _NavTab extends StatelessWidget {
  final _TabData data;
  final bool selected;
  final bool isCenter;
  final VoidCallback onTap;

  const _NavTab({
    required this.data,
    required this.selected,
    required this.isCenter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: data.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox.expand(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            tween: Tween(
              begin: 0.0,
              // Center never "selects" visually — always 0
              end: (!isCenter && selected) ? 1.0 : 0.0,
            ),
            builder: (context, t, _) {
              // Center tab: always brand color
              // Regular tab: lerp from tertiary → brand
              final color = isCenter
                  ? AppColors.primary
                  : Color.lerp(AppColors.textTertiary, AppColors.primary, t)!;

              final iconSize = isCenter ? 40.0 : 26.0;

              // Center: always broken outline
              // Regular: broken → filled based on animation
              final icon = isCenter
                  ? data.outline
                  : (t > 0.5 ? data.filled : data.outline);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform.scale(
                    scale: 1.0 + 0.06 * t,
                    child: Icon(icon, size: iconSize, color: color),
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    width: (!isCenter && selected) ? 5 : 0,
                    height: (!isCenter && selected) ? 5 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: t),
                      shape: BoxShape.circle,
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
