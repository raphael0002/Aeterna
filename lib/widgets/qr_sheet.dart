import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/app_theme.dart';

/// QR panel with notched top and floating grabber.
/// The QR image scales to fit the parent height minus caption/padding.
class QrSheet extends StatelessWidget {
  final String data;
  final VoidCallback? onExpand;
  final String caption;

  const QrSheet({
    super.key,
    required this.data,
    this.onExpand,
    this.caption = 'Scan to open this memory',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipPath(
          clipper: const _QrSheetClipper(),
          child: Container(
            width: double.infinity,
            color: Colors.white,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final w = constraints.maxWidth;

                // Reserve for top notch (~30) + caption row (~40) + padding
                final reserved = 30.0 + 40.0 + 40.0;
                final available = (h - reserved).clamp(120.0, 280.0);
                final qrSize = available.clamp(120.0, w - 100).toDouble();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Center(
                          child: Stack(
                            children: [
                              Center(
                                child: QrImageView(
                                  data: data,
                                  size: qrSize,
                                  padding: EdgeInsets.zero,
                                  backgroundColor: Colors.transparent,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.textPrimary,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (onExpand != null)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Material(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    // elevation: 1,
                                    child: InkWell(
                                      onTap: onExpand,
                                      borderRadius: BorderRadius.circular(10),
                                      child: const SizedBox(
                                        width: 38,
                                        height: 38,
                                        child: Icon(
                                          Amicons.iconly_send_fill,
                                          size: 18,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: AppType.small.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
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
    );
  }
}

class _QrSheetClipper extends CustomClipper<Path> {
  const _QrSheetClipper();

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

    return Path()
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
  }

  @override
  bool shouldReclip(covariant _QrSheetClipper old) => false;
}
