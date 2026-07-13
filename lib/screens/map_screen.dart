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

class _MapScreenState extends ConsumerState<MapScreen> {
  final _controller = MapController();
  Ticket? _selected;
  bool _showJourney = true;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _fitAll(List<Ticket> located) {
    if (located.isEmpty) return;
    if (located.length == 1) {
      _controller.move(LatLng(located.first.lat!, located.first.lng!), 10);
      return;
    }
    final bounds = LatLngBounds.fromPoints(
      located.map((t) => LatLng(t.lat!, t.lng!)).toList(),
    );
    _controller.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(ticketStoreProvider);
    final located = store.tickets.where((t) => t.hasLocation).toList();
    final path = journeyPath(store.tickets);

    // ✅ Return Stack directly — HomeShell's Scaffold gives us full body
    return Stack(
      fit: StackFit.expand,
      children: [
        // ── Full-screen map ────────────────────────────────
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: located.isNotEmpty
                ? LatLng(located.first.lat!, located.first.lng!)
                : const LatLng(20, 0),
            initialZoom: located.isNotEmpty ? 4 : 2.5,
            minZoom: 2,
            maxZoom: 18,
            onTap: (_, _) => setState(() => _selected = null),
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.memoryticket.app',
              maxZoom: 20,
            ),
            if (_showJourney && path.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: path,
                    strokeWidth: 2.5,
                    color: AppColors.primary.withValues(alpha: 0.7),
                    pattern: StrokePattern.dashed(segments: const [8.0, 6.0]),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final t in located)
                  Marker(
                    point: LatLng(t.lat!, t.lng!),
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selected = t);
                        _controller.move(
                          LatLng(t.lat!, t.lng!),
                          _controller.camera.zoom < 6
                              ? 6
                              : _controller.camera.zoom,
                        );
                      },
                      child: _CategoryMarker(
                        category: t.category,
                        selected: _selected?.id == t.id,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // ── Top floating pill ──────────────────────────────
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _StatPill(
                  icon: Icons.place_rounded,
                  text: located.isEmpty
                      ? 'No pins yet'
                      : '${located.length} on map',
                ),
                const Spacer(),
                if (path.length > 1)
                  _MapToggleButton(
                    icon: Icons.timeline_rounded,
                    active: _showJourney,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _showJourney = !_showJourney);
                    },
                  ),
              ],
            ),
          ),
        ),

        // ── Right-side zoom controls ───────────────────────
        Positioned(
          right: 12,
          // Lifted extra when preview card is showing
          bottom: _selected != null ? 260 : 130,
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
              const SizedBox(height: 8),
              _MapButton(
                icon: Icons.fit_screen_rounded,
                onTap: () => _fitAll(located),
              ),
            ],
          ),
        ),

        // ── Selected ticket preview ────────────────────────
        if (_selected != null)
          Positioned(
            left: 0,
            right: 0,
            // Sits above the floating nav (nav height ~76 + 24 breathing)
            bottom: 100,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _TicketPreview(
                ticket: _selected!,
                onTap: () => context.push('/ticket/${_selected!.id}'),
                onClose: () => setState(() => _selected = null),
              ),
            ),
          ),

        // ── Empty state ────────────────────────────────────
        if (located.isEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 150,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 24),
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
                    Container(
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.explore_outlined,
                        color: AppColors.primary,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No pinned memories',
                      style: AppType.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Add a location when you create a ticket',
                      style: AppType.small.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Category marker ───────────────────────────────────────────────
class _CategoryMarker extends StatelessWidget {
  final TicketCategory category;
  final bool selected;

  const _CategoryMarker({required this.category, required this.selected});

  @override
  Widget build(BuildContext context) {
    final size = selected ? 46.0 : 36.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: category.color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: category.color.withValues(alpha: selected ? 0.55 : 0.3),
            blurRadius: selected ? 14 : 8,
            spreadRadius: selected ? 2 : 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(category.icon, color: Colors.white, size: selected ? 22 : 18),
    );
  }
}

// ─── Preview card ──────────────────────────────────────────────────
class _TicketPreview extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const _TicketPreview({
    required this.ticket,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0x293C2814),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: ticket.category.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  ticket.category.icon,
                  color: ticket.category.color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
                    const SizedBox(height: 2),
                    Text(
                      '${DateFormat('MMM d, yyyy').format(ticket.date)}'
                      '${ticket.venue.isEmpty ? '' : ' · ${ticket.venue}'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.small.copyWith(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 18),
                color: AppColors.textTertiary,
                onPressed: onClose,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Map UI controls ───────────────────────────────────────────────
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

class _MapToggleButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _MapToggleButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
            child: Icon(
              icon,
              size: 20,
              color: active ? Colors.white : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StatPill({required this.icon, required this.text});

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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppType.small.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
