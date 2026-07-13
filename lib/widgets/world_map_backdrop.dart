import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_maps/maps.dart';

/// World map background that can extend behind the entire screen.
///
/// Place this behind all content in your Stack:
///
/// Stack(
///   children: [
///     const Positioned.fill(
///       child: DecoratedBox(
///         decoration: BoxDecoration(color: AppColors.primary),
///       ),
///     ),
///
///     const Positioned.fill(
///       child: WorldMapBackdrop(),
///     ),
///
///     ...
///   ],
/// )
class WorldMapBackdrop extends StatelessWidget {
  final double opacity;
  final double scale;
  final double offsetX;
  final double offsetY;

  const WorldMapBackdrop({
    super.key,
    this.opacity = 0.9,
    this.scale = 1.75,
    this.offsetX = 0.0,
    this.offsetY = -0.02,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;

            return Transform.translate(
              offset: Offset(offsetX * w, offsetY * h),
              child: Transform.scale(
                scale: scale,
                alignment: Alignment.topCenter,
                child: SizedBox(
                  width: w,
                  height: h,
                  child: SfMaps(
                    layers: [
                      MapShapeLayer(
                        source: const MapShapeSource.asset(
                          'assets/maps/world.json',
                          shapeDataField: 'name',
                        ),
                        color: const Color(0xFF9C3C1E).withValues(alpha: 0.55),
                        strokeWidth: 0,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
