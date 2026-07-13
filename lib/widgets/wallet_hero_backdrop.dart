import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'world_map_backdrop.dart';

/// Wraps a wallet screen with the orange world-map hero at the top.
/// Use inside your HomeShell wallet tab.
class WalletHeroBackdrop extends StatelessWidget {
  final Widget child;
  final double heroHeight;
  final Widget? heroContent;

  const WalletHeroBackdrop({
    super.key,
    required this.child,
    this.heroHeight = 220,
    this.heroContent,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Orange hero band with world map — spans top portion
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: heroHeight,
          child: Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primary),
                ),
              ),
              const Positioned.fill(child: WorldMapBackdrop()),
              if (heroContent != null)
                Positioned.fill(
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: heroContent!,
                    ),
                  ),
                ),
            ],
          ),
        ),
        // The actual wallet stack sits on top
        Positioned.fill(child: child),
      ],
    );
  }
}
