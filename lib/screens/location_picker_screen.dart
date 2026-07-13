import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../theme/app_theme.dart';

class LocationResult {
  final LatLng? point;
  const LocationResult(this.point);
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initial;
  const LocationPickerScreen({super.key, this.initial});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late final MapController _controller;
  LatLng? _picked;

  @override
  void initState() {
    super.initState();
    _controller = MapController();
    _picked = widget.initial;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap(TapPosition _, LatLng point) {
    HapticFeedback.selectionClick();
    setState(() => _picked = point);
  }

  void _confirm() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop(LocationResult(_picked));
  }

  void _clear() {
    HapticFeedback.lightImpact();
    setState(() => _picked = null);
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.initial ?? const LatLng(20, 0);
    final initialZoom = widget.initial != null ? 12.0 : 2.5;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────
          Positioned.fill(
            child: FlutterMap(
              mapController: _controller,
              options: MapOptions(
                initialCenter: initial,
                initialZoom: initialZoom,
                minZoom: 2,
                maxZoom: 18,
                onTap: _onTap,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.memory_ticket',
                  tileBuilder: (context, tileWidget, tile) {
                    return ColorFiltered(
                      // Soft desaturation for cleaner look
                      colorFilter: const ColorFilter.matrix([
                        0.85,
                        0.10,
                        0.05,
                        0,
                        4,
                        0.10,
                        0.90,
                        0.00,
                        0,
                        4,
                        0.05,
                        0.05,
                        0.90,
                        0,
                        4,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: tileWidget,
                    );
                  },
                ),
                if (_picked != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _picked!,
                        width: 60,
                        height: 60,
                        alignment: Alignment.topCenter,
                        child: const _PinMarker(),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Crosshair (subtle center indicator) ────────────
          if (_picked == null)
            IgnorePointer(
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Top bar ────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  _MapButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Center(child: _MapPill(text: 'Tap to drop a pin')),
                  ),
                  if (_picked != null)
                    _MapButton(icon: Icons.close_rounded, onTap: _clear)
                  else
                    const SizedBox(width: 42),
                ],
              ),
            ),
          ),

          // ── Zoom controls (right side) ─────────────────────
          Positioned(
            right: 12,
            bottom: 200,
            child: Column(
              children: [
                _MapButton(
                  icon: Icons.add_rounded,
                  onTap: () {
                    final z = _controller.camera.zoom;
                    _controller.move(_controller.camera.center, z + 1);
                  },
                ),
                const SizedBox(height: 8),
                _MapButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    final z = _controller.camera.zoom;
                    _controller.move(_controller.camera.center, z - 1);
                  },
                ),
              ],
            ),
          ),

          // ── Bottom sheet with coordinates + confirm ────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x293C2814),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _picked != null
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : AppColors.surfaceInset,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _picked != null
                                  ? Icons.place_rounded
                                  : Icons.location_searching_rounded,
                              size: 20,
                              color: _picked != null
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _picked != null
                                      ? 'Location selected'
                                      : 'No location',
                                  style: AppType.body.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _picked != null
                                      ? '${_picked!.latitude.toStringAsFixed(4)}, ${_picked!.longitude.toStringAsFixed(4)}'
                                      : 'Tap anywhere on the map to set',
                                  style: AppType.small.copyWith(
                                    color: AppColors.textTertiary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: _confirm,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            _picked != null
                                ? 'Save location'
                                : 'Save without location',
                            style: AppType.button.copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable map UI pieces ──────────────────────────────────────
class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0x143C2814),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

class _MapPill extends StatelessWidget {
  final String text;
  const _MapPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: const Color(0x143C2814),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppType.small.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _PinMarker extends StatelessWidget {
  const _PinMarker();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [_PinBody(), SizedBox(height: 2), _PinShadow()],
    );
  }
}

class _PinBody extends StatelessWidget {
  const _PinBody();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.place_rounded, color: Colors.white, size: 22),
    );
  }
}

class _PinShadow extends StatelessWidget {
  const _PinShadow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
