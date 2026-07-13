import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/ticket.dart';
import '../providers/filter_providers.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/world_map_backdrop.dart';
import 'calendar_screen.dart'; // ← imports CompactTicketRow

const _kSheetBg = Color(0xFFF0EAE0);

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  void _open(BuildContext c, Ticket t) => c.push('/ticket/${t.id}');
  void _add(BuildContext c) => c.push('/new');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(ticketStoreProvider);
    final all = store.tickets;
    final filter = ref.watch(categoryFilterProvider);

    final tickets = filter == null
        ? all
        : all.where((t) => t.category == filter).toList();

    final counts = <TicketCategory, int>{};
    for (final t in all) {
      counts[t.category] = (counts[t.category] ?? 0) + 1;
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final topInset = mq.padding.top;
          final screenH = constraints.maxHeight;
          final heroH = (screenH * 0.26).clamp(220.0, 280.0);

          return Stack(
            children: [
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primary),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: const WorldMapBackdrop(
                  opacity: 0.8,
                  scale: 3.2,
                  offsetY: -0.9,
                  offsetX: -0.4,
                ),
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: _Hero(
                    total: all.length,
                    filteredCount: tickets.length,
                    category: filter,
                    counts: counts,
                    onCategoryChanged: (c) =>
                        ref.read(categoryFilterProvider.notifier).state = c,
                  ),
                ),
              ),

              Positioned(
                top: heroH,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipPath(
                  clipper: const _SheetTopClipper(),
                  child: Container(
                    color: _kSheetBg,
                    child: all.isEmpty
                        ? _EmptyGallery(onAdd: () => _add(context))
                        : tickets.isEmpty
                        ? _EmptyFilter(category: filter!)
                        : _CompactList(
                            tickets: tickets,
                            onTap: (t) => _open(context, t),
                          ),
                  ),
                ),
              ),

              Positioned(
                top: heroH + 5,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 38,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final int total;
  final int filteredCount;
  final TicketCategory? category;
  final Map<TicketCategory, int> counts;
  final ValueChanged<TicketCategory?> onCategoryChanged;

  const _Hero({
    required this.total,
    required this.filteredCount,
    required this.category,
    required this.counts,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GALLERY',
            style: monoStyle(
              size: 11,
              color: Colors.white.withValues(alpha: 0.75),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.4),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$filteredCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 44,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              if (category != null) ...[
                const SizedBox(width: 6),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '/ $total',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  filteredCount == 1 ? 'memory' : 'memories',
                  style: AppType.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _HeroChip(
                  label: 'All',
                  icon: Icons.apps_rounded,
                  count: total,
                  selected: category == null,
                  onTap: () => onCategoryChanged(null),
                ),
                const SizedBox(width: 8),
                for (final c in TicketCategory.values) ...[
                  _HeroChip(
                    label: c.label,
                    icon: c.icon,
                    count: counts[c] ?? 0,
                    selected: category == c,
                    onTap: () => onCategoryChanged(category == c ? null : c),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _HeroChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: selected ? AppColors.primary : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppType.small.copyWith(
                color: selected ? AppColors.primary : Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: selected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactList extends StatelessWidget {
  final List<Ticket> tickets;
  final void Function(Ticket) onTap;

  const _CompactList({required this.tickets, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your memories',
                  style: AppType.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${tickets.length} ${tickets.length == 1 ? "stub" : "stubs"}',
                style: AppType.small.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
            itemCount: tickets.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) => CompactTicketRow(
              ticket: tickets[i],
              onTap: () => onTap(tickets[i]),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyGallery extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyGallery({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Your gallery is empty',
              style: AppType.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Saved memories appear here\nas a beautiful collection.',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Capture a memory'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                textStyle: AppType.button,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  final TicketCategory category;
  const _EmptyFilter({required this.category});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: category.bg,
                shape: BoxShape.circle,
              ),
              child: Icon(category.icon, size: 28, color: category.color),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${category.label.toLowerCase()} memories yet',
              style: AppType.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Add a ${category.label.toLowerCase()} ticket to see it here',
              style: AppType.small.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
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
  bool shouldReclip(covariant _SheetTopClipper old) => false;
}
