// lib/screens/wallet_screen.dart
import 'package:amicons/amicons.dart';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/backup.dart';
import '../models/ticket.dart';
import '../providers/filter_providers.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_ticket_card.dart';
import '../widgets/ticket_skeleton.dart';
import '../widgets/world_map_backdrop.dart';

// ─── Filter helper (public, reusable) ──────────────────────────────
List<Ticket> filterTickets(
  List<Ticket> all, {
  String query = '',
  TicketCategory? category,
  bool starredOnly = false,
}) {
  final q = query.trim().toLowerCase();
  return all.where((t) {
    if (category != null && t.category != category) return false;
    if (starredOnly && !t.favorite) return false;
    if (q.isNotEmpty) {
      final hay = '${t.title} ${t.venue} ${t.note} ${t.tags.join(' ')}'
          .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    return true;
  }).toList();
}

const _kSheetBg = Color(0xFFF0EAE0);

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  void _openDetail(BuildContext c, Ticket t) => c.push('/ticket/${t.id}');
  void _addTicket(BuildContext c) => c.push('/new');

  Future<void> _exportBackup(BuildContext context, WidgetRef ref) async {
    try {
      final json = await encodeBackup(ref.read(ticketStoreProvider).tickets);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/memory_ticket_backup.json');
      await file.writeAsString(json);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Aeterna backup',
        subject: 'Aeterna Backup',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importBackup(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      const group = XTypeGroup(label: 'backup', extensions: ['json']);
      final file = await openFile(acceptedTypeGroups: [group]);
      if (file == null) return;
      final n = await ref
          .read(ticketStoreProvider)
          .importBackup(await file.readAsString());
      messenger.showSnackBar(
        SnackBar(content: Text('Imported $n stub${n == 1 ? '' : 's'}')),
      );
    } on FormatException {
      messenger.showSnackBar(
        const SnackBar(content: Text('That file is not a Aeterna backup')),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _openMoreMenu(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _MoreSheet(
        onExport: () {
          Navigator.pop(ctx);
          _exportBackup(context, ref);
        },
        onImport: () {
          Navigator.pop(ctx);
          _importBackup(context, ref);
        },
        onRecap: () {
          Navigator.pop(ctx);
          context.push('/recap');
        },
        onAdd: () {
          Navigator.pop(ctx);
          _addTicket(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(ticketStoreProvider);
    final all = store.tickets;
    final category = ref.watch(categoryFilterProvider);
    final starred = ref.watch(starredOnlyProvider);
    final tickets = filterTickets(
      all,
      category: category,
      starredOnly: starred,
    );

    final counts = _computeCounts(all, starredOnly: starred);

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final topInset = mq.padding.top;
          final screenH = constraints.maxHeight;

          final heroH = (screenH * 0.30).clamp(250.0, 310.0);

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
                    totalCount: all.length,
                    filteredCount: tickets.length,
                    starred: starred,
                    category: category,
                    counts: counts,
                    onStarredChanged: (v) {
                      HapticFeedback.selectionClick();
                      ref.read(starredOnlyProvider.notifier).state = v;
                    },
                    onCategoryChanged: (c) {
                      HapticFeedback.selectionClick();
                      ref.read(categoryFilterProvider.notifier).state = c;
                    },
                    onMore: () => _openMoreMenu(context, ref),
                    onRecap: () => context.push('/recap'),
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
                    child: _SheetContent(
                      total: all.length,
                      tickets: tickets,
                      category: category,
                      starred: starred,
                      loading: !store.isLoaded,
                      onTicketTap: (t) => _openDetail(context, t),
                      onAdd: () => _addTicket(context),
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

  Map<TicketCategory, int> _computeCounts(
    List<Ticket> all, {
    required bool starredOnly,
  }) {
    final result = {for (final c in TicketCategory.values) c: 0};
    for (final t in all) {
      if (starredOnly && !t.favorite) continue;
      result[t.category] = (result[t.category] ?? 0) + 1;
    }
    return result;
  }
}

// ═══ HERO ══════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final int totalCount;
  final int filteredCount;
  final bool starred;
  final TicketCategory? category;
  final Map<TicketCategory, int> counts;
  final ValueChanged<bool> onStarredChanged;
  final ValueChanged<TicketCategory?> onCategoryChanged;
  final VoidCallback onMore;
  final VoidCallback onRecap;

  const _Hero({
    required this.totalCount,
    required this.filteredCount,
    required this.starred,
    required this.category,
    required this.counts,
    required this.onStarredChanged,
    required this.onCategoryChanged,
    required this.onMore,
    required this.onRecap,
  });

  @override
  Widget build(BuildContext context) {
    final isFiltered = starred || category != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _HeroIconButton(
                icon: Amicons.iconly_star_fill,
                onTap: onRecap,
                tooltip: 'Year in Stubs',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: _TabPill(
                    tabs: const ['All stubs', 'Starred'],
                    selectedIndex: starred ? 1 : 0,
                    onChanged: (i) => onStarredChanged(i == 1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _HeroIconButton(
                icon: Amicons.iconly_more_square_fill,
                onTap: onMore,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 44,
                      letterSpacing: -1,
                      height: 1,
                    ),
                    children: [
                      TextSpan(text: '$filteredCount'),
                      if (isFiltered)
                        TextSpan(
                          text: ' / $totalCount',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    filteredCount == 1 ? 'memory' : 'memories',
                    style: AppType.small.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                _HeroCategoryChip(
                  label: 'All',
                  icon: Amicons.iconly_category_fill,
                  count: counts.values.fold(0, (a, b) => a + b),
                  selected: category == null,
                  onTap: () => onCategoryChanged(null),
                ),
                const SizedBox(width: 8),
                for (final c in TicketCategory.values) ...[
                  _HeroCategoryChip(
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

class _HeroIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  const _HeroIconButton({
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

class _TabPill extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _TabPill({
    required this.tabs,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < tabs.length; i++)
            _tab(i, tabs[i], i == selectedIndex),
        ],
      ),
    );
  }

  Widget _tab(int i, String label, bool active) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(i);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: AppType.small.copyWith(
            color: active ? AppColors.primary : Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _HeroCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _HeroCategoryChip({
    required this.label,
    required this.icon,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? Colors.white
                : Colors.white.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
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
                style: AppType.small.copyWith(
                  color: selected ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ SHEET CONTENT ═════════════════════════════════════════════════
class _SheetContent extends StatelessWidget {
  final int total;
  final List<Ticket> tickets;
  final TicketCategory? category;
  final bool starred;
  final void Function(Ticket) onTicketTap;
  final VoidCallback onAdd;
  final bool loading;

  const _SheetContent({
    required this.total,
    required this.tickets,
    required this.category,
    required this.starred,
    required this.onTicketTap,
    required this.onAdd,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: TicketListSkeleton(),
      );
    }
    if (total == 0) return _EmptyWallet(onAdd: onAdd);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (category != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: category!.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  _headingFor(category, starred),
                  style: AppType.h3.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${tickets.length} ${tickets.length == 1 ? 'stub' : 'stubs'}',
                style: AppType.small.copyWith(
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tickets.isEmpty
              ? const _EmptyFilter()
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (ctx, i) => MemoryTicketCard(
                    ticket: tickets[i],
                    variant: MemoryCardVariant.compact,
                    onTap: () => onTicketTap(tickets[i]),
                  ),
                ),
        ),
      ],
    );
  }

  String _headingFor(TicketCategory? c, bool starred) {
    if (c != null && starred) return 'Starred · ${c.label}';
    if (c != null) return c.label;
    if (starred) return 'Starred memories';
    return 'All memories';
  }
}

// ═══ EMPTY STATES ══════════════════════════════════════════════════
class _EmptyWallet extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyWallet({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: const Icon(
                Amicons.iconly_ticket_fill,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your first ticket is waiting',
              textAlign: TextAlign.center,
              style: AppType.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Every moment deserves a stub.\nTap below to start your collection.',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Amicons.iconly_plus_broken, size: 20),
                label: const Text('Capture a memory'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  textStyle: AppType.button,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFilter extends StatelessWidget {
  const _EmptyFilter();

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
                color: AppColors.surfaceInset,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Amicons.iconly_search_fill,
                size: 28,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No stubs match your filters',
              style: AppType.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try switching category or clearing starred',
              style: AppType.small.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ MORE BOTTOM SHEET ═════════════════════════════════════════════
class _MoreSheet extends StatelessWidget {
  final VoidCallback onExport;
  final VoidCallback onImport;
  final VoidCallback onRecap;
  final VoidCallback onAdd;

  const _MoreSheet({
    required this.onExport,
    required this.onImport,
    required this.onRecap,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x293C2814),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),
            _SheetTile(
              icon: Amicons.iconly_plus_fill,
              label: 'New ticket',
              subtitle: 'Capture a fresh memory',
              onTap: onAdd,
              accent: true,
            ),
            const _SheetDivider(),
            _SheetTile(
              icon: Amicons.iconly_star_fill,
              label: 'Year in Stubs',
              subtitle: 'Your recap for this year',
              onTap: onRecap,
            ),
            const _SheetDivider(),
            _SheetTile(
              icon: Amicons.iconly_upload_fill,
              label: 'Export backup',
              subtitle: 'Save all tickets to a JSON file',
              onTap: onExport,
            ),
            const _SheetDivider(),
            _SheetTile(
              icon: Amicons.iconly_download_fill,
              label: 'Import backup',
              subtitle: 'Restore from a backup file',
              onTap: onImport,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final bool accent;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent ? AppColors.primary : AppColors.primaryFaint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: accent ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.body.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppType.small.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Amicons.iconly_arrow_right_2_fill,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetDivider extends StatelessWidget {
  const _SheetDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.borderSubtle,
    );
  }
}

// ═══ NOTCHED SHEET CLIPPER ═════════════════════════════════════════
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
