// lib/screens/map_screen.dart
import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../models/ticket.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';

List<LatLng> journeyPath(List<Ticket> tickets) {
  final located = tickets.where((t) => t.hasLocation).toList()
    ..sort((a, b) => a.date.compareTo(b.date));
  return [for (final t in located) LatLng(t.lat!, t.lng!)];
}

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with SingleTickerProviderStateMixin {
  final _mapCtrl = MapController();
  Ticket? _selected;
  bool _showJourney = true;

  late final AnimationController _previewCtrl;
  late final Animation<Offset> _previewSlide;
  late final Animation<double> _previewFade;

  @override
  void initState() {
    super.initState();
    _previewCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _previewSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOutCubic),
        );
    _previewFade = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _previewCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _mapCtrl.dispose();
    _previewCtrl.dispose();
    super.dispose();
  }

  void _selectTicket(Ticket t) {
    HapticFeedback.selectionClick();
    setState(() => _selected = t);
    _previewCtrl.forward(from: 0);
    _mapCtrl.move(
      LatLng(t.lat!, t.lng!),
      _mapCtrl.camera.zoom < 8 ? 8 : _mapCtrl.camera.zoom,
    );
  }

  void _dismissPreview() {
    HapticFeedback.selectionClick();
    _previewCtrl.reverse().then((_) {
      if (mounted) setState(() => _selected = null);
    });
  }

  void _fitAll(List<Ticket> located) {
    if (located.isEmpty) return;
    HapticFeedback.lightImpact();
    if (located.length == 1) {
      _mapCtrl.move(LatLng(located.first.lat!, located.first.lng!), 10);
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      located.map((t) => LatLng(t.lat!, t.lng!)).toList(),
    );
    _mapCtrl.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  void _zoomIn() {
    HapticFeedback.lightImpact();
    final z = _mapCtrl.camera.zoom;
    if (z < 18) _mapCtrl.move(_mapCtrl.camera.center, z + 1);
  }

  void _zoomOut() {
    HapticFeedback.lightImpact();
    final z = _mapCtrl.camera.zoom;
    if (z > 2) _mapCtrl.move(_mapCtrl.camera.center, z - 1);
  }

  Widget _warmTileBuilder(
    BuildContext context,
    Widget tileWidget,
    TileImage tile,
  ) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.95,
        0.05,
        0.00,
        0.00,
        6.0,
        0.02,
        0.93,
        0.02,
        0.00,
        3.0,
        0.00,
        0.00,
        0.88,
        0.00,
        0.0,
        0.00,
        0.00,
        0.00,
        1.00,
        0.0,
      ]),
      child: tileWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(ticketStoreProvider);
    final located = store.tickets.where((t) => t.hasLocation).toList();
    final path = journeyPath(store.tickets);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Map ───────────────────────────────────────────
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: located.isNotEmpty
                ? LatLng(located.first.lat!, located.first.lng!)
                : const LatLng(20, 0),
            initialZoom: located.isNotEmpty ? 4 : 2.5,
            minZoom: 2,
            maxZoom: 18,
            onTap: (_, __) {
              if (_selected != null) _dismissPreview();
            },
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
              userAgentPackageName: 'com.memoryticket.app',
              maxZoom: 20,
              tileSize: 512,
              zoomOffset: -1,
              tileBuilder: _warmTileBuilder,
            ),
            if (_showJourney && path.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: path,
                    strokeWidth: 2.5,
                    color: AppColors.primary.withValues(alpha: 0.6),
                    pattern: StrokePattern.dashed(segments: const [10.0, 6.0]),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final t in located)
                  Marker(
                    point: LatLng(t.lat!, t.lng!),
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () => _selectTicket(t),
                      child: _Pin(
                        category: t.category,
                        active: _selected?.id == t.id,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // ── Top bar ───────────────────────────────────────
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _MapTopBar(
            pinCount: located.length,
            showJourney: _showJourney,
            hasPath: path.length > 1,
            onToggleJourney: () {
              HapticFeedback.selectionClick();
              setState(() => _showJourney = !_showJourney);
            },
          ),
        ),

        // ── Controls ──────────────────────────────────────
        Positioned(
          right: 16,
          bottom: _selected != null ? bottomPad + 200 : bottomPad + 80,
          child: _MapControls(
            onZoomIn: _zoomIn,
            onZoomOut: _zoomOut,
            onFitAll: () => _fitAll(located),
            hasLocated: located.isNotEmpty,
          ),
        ),

        // ── Preview card ──────────────────────────────────
        if (_selected != null)
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPad + 70,
            child: SlideTransition(
              position: _previewSlide,
              child: FadeTransition(
                opacity: _previewFade,
                child: _PreviewCard(
                  ticket: _selected!,
                  onTap: () => context.push('/ticket/${_selected!.id}'),
                  onClose: _dismissPreview,
                ),
              ),
            ),
          ),

        // ── Empty state ───────────────────────────────────
        if (located.isEmpty)
          Positioned(
            left: 24,
            right: 24,
            bottom: bottomPad + 100,
            child: const _EmptyOverlay(),
          ),
      ],
    );
  }
}

// ═══ MAP TOP BAR ══════════════════════════════════════════════════
class _MapTopBar extends StatelessWidget {
  final int pinCount;
  final bool showJourney;
  final bool hasPath;
  final VoidCallback onToggleJourney;

  const _MapTopBar({
    required this.pinCount,
    required this.showJourney,
    required this.hasPath,
    required this.onToggleJourney,
  });

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 8, 16, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.0),
          ],
          stops: const [0.6, 1.0],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Amicons.iconly_location_fill,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  pinCount == 0
                      ? 'No pins'
                      : '$pinCount ${pinCount == 1 ? 'pin' : 'pins'}',
                  style: AppType.small.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (hasPath)
            _JourneyChip(active: showJourney, onTap: onToggleJourney),
        ],
      ),
    );
  }
}

class _JourneyChip extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _JourneyChip({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0F000000),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Amicons.iconly_activity_fill,
              size: 15,
              color: active ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Journey',
              style: AppType.small.copyWith(
                color: active ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ MAP CONTROLS ═════════════════════════════════════════════════
class _MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFitAll;
  final bool hasLocated;

  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFitAll,
    required this.hasLocated,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CtrlButton(
            icon: Icons.add_rounded,
            onTap: onZoomIn,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
          Container(height: 1, width: 28, color: AppColors.borderSubtle),
          _CtrlButton(
            icon: Icons.remove_rounded,
            onTap: onZoomOut,
            borderRadius: hasLocated
                ? BorderRadius.zero
                : const BorderRadius.vertical(bottom: Radius.circular(14)),
          ),
          if (hasLocated) ...[
            Container(height: 1, width: 28, color: AppColors.borderSubtle),
            _CtrlButton(
              icon: Amicons.iconly_scan_fill,
              onTap: onFitAll,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(14),
              ),
              iconSize: 18,
            ),
          ],
        ],
      ),
    );
  }
}

class _CtrlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;
  final double iconSize;

  const _CtrlButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.primary.withValues(alpha: 0.08),
        highlightColor: AppColors.primary.withValues(alpha: 0.04),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: iconSize, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ═══ PIN ══════════════════════════════════════════════════════════
class _Pin extends StatelessWidget {
  final TicketCategory category;
  final bool active;

  const _Pin({required this.category, required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: active ? 1.2 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutBack,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: category.color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: active ? 3.5 : 2.5),
          boxShadow: [
            BoxShadow(
              color: category.color.withValues(alpha: active ? 0.5 : 0.25),
              blurRadius: active ? 16 : 8,
              spreadRadius: active ? 1 : 0,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(category.icon, color: Colors.white, size: active ? 18 : 16),
      ),
    );
  }
}

// ═══ PREVIEW CARD ═════════════════════════════════════════════════
class _PreviewCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _PreviewCard({
    required this.ticket,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.primary.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ticket.category.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    ticket.category.icon,
                    color: ticket.category.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.body.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Amicons.iconly_calendar,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d, yyyy').format(ticket.date),
                            style: AppType.small.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          if (ticket.venue.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: AppColors.textTertiary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                ticket.venue,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppType.small.copyWith(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 34,
                      height: 34,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onPressed: onClose,
                      ),
                    ),
                    const Icon(
                      Amicons.iconly_arrow_right_2,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══ EMPTY OVERLAY ════════════════════════════════════════════════
class _EmptyOverlay extends StatelessWidget {
  const _EmptyOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            child: Icon(
              Amicons.iconly_discovery_fill,
              color: AppColors.primary,
              size: 56,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'No pinned memories',
            style: AppType.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Add a location when creating a ticket\nto see it on the map',
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
