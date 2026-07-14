// lib/screens/search_screen.dart
import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/ticket.dart';
import '../providers/filter_providers.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/memory_ticket_card.dart';
import '../widgets/ticket_skeleton.dart';
import '../widgets/world_map_backdrop.dart';
import 'wallet_screen.dart' show filterTickets;

const _kSheetBg = Color(0xFFF0EAE0);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _controller;
  final _focus = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(searchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _setQuery(String v) {
    ref.read(searchQueryProvider.notifier).state = v;
  }

  void _clear() {
    _controller.clear();
    _setQuery('');
    _focus.requestFocus();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final store = ref.watch(ticketStoreProvider);
    final all = store.tickets;
    final query = ref.watch(searchQueryProvider);
    final hasQuery = query.trim().isNotEmpty;
    final results = hasQuery ? filterTickets(all, query: query) : all;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final topInset = mq.padding.top;
          final screenH = constraints.maxHeight;
          final heroH = (screenH * 0.22).clamp(170.0, 230.0);

          return Stack(
            children: [
              // ── Orange background ───────────────────────
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primary),
                ),
              ),

              // ── World map backdrop ──────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: const WorldMapBackdrop(
                  opacity: 0.6,
                  scale: 3.2,
                  offsetY: -0.9,
                  offsetX: -0.4,
                ),
              ),

              // ── Hero content ────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: _SearchHero(
                    totalCount: all.length,
                    resultCount: results.length,
                    hasQuery: hasQuery,
                    query: query,
                    controller: _controller,
                    focusNode: _focus,
                    onChanged: _setQuery,
                    onClear: _clear,
                  ),
                ),
              ),

              // ── Sheet ──────────────────────────────────
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
                      tickets: results,
                      loading: !store.isLoaded,
                      hasQuery: hasQuery,
                      query: query,
                      total: all.length,
                      onTicketTap: (t) => context.push('/ticket/${t.id}'),
                    ),
                  ),
                ),
              ),

              // ── Grabber ─────────────────────────────────
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

// ═══ SEARCH HERO ══════════════════════════════════════════════════
class _SearchHero extends StatelessWidget {
  final int totalCount;
  final int resultCount;
  final bool hasQuery;
  final String query;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchHero({
    required this.totalCount,
    required this.resultCount,
    required this.hasQuery,
    required this.query,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Text(
                  'Search',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                    letterSpacing: -0.5,
                    height: 1,
                  ),
                ),
              ),
              // Result count badge
              if (hasQuery)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$resultCount ${resultCount == 1 ? 'result' : 'results'}',
                    style: AppType.small.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),

          const Spacer(),

          // ── Search field ─────────────────────────────
          _HeroSearchField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onClear: onClear,
          ),
        ],
      ),
    );
  }
}

// ─── Search field (hero variant — glass style) ───────────────────
class _HeroSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _HeroSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_HeroSearchField> createState() => _HeroSearchFieldState();
}

class _HeroSearchFieldState extends State<_HeroSearchField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocus);
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onFocus() => setState(() => _focused = widget.focusNode.hasFocus);
  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      height: 48,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: _focused ? 0.3 : 0.25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _focused
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.15),
          width: _focused ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Amicons.iconly_search,
            size: 19,
            color: Colors.white.withValues(alpha: _focused ? 1.0 : 0.7),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: widget.onChanged,
              textInputAction: TextInputAction.search,
              style: AppType.body.copyWith(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Memories, places, tags…',
                hintStyle: AppType.body.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
                isDense: true,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 150),
            child: widget.controller.text.isNotEmpty
                ? GestureDetector(
                    key: const ValueKey('clear'),
                    onTap: widget.onClear,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(key: ValueKey('none'), width: 10),
          ),
        ],
      ),
    );
  }
}

// ═══ SHEET CONTENT ════════════════════════════════════════════════
class _SheetContent extends StatelessWidget {
  final List<Ticket> tickets;
  final bool loading;
  final bool hasQuery;
  final String query;
  final int total;
  final void Function(Ticket) onTicketTap;

  const _SheetContent({
    required this.tickets,
    required this.loading,
    required this.hasQuery,
    required this.query,
    required this.total,
    required this.onTicketTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 30),
        child: TicketListSkeleton(),
      );
    }

    if (total == 0) return const _EmptyCollection();

    return Column(
      children: [
        // ── Section header ──────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hasQuery ? 'Results' : 'All memories',
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

        // ── List / empty ────────────────────────────────
        Expanded(
          child: tickets.isEmpty
              ? _NoResults(query: query)
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: tickets.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, i) => MemoryTicketCard(
                    ticket: tickets[i],
                    variant: MemoryCardVariant.compact,
                    onTap: () => onTicketTap(tickets[i]),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Empty collection (no tickets at all) ────────────────────────
class _EmptyCollection extends StatelessWidget {
  const _EmptyCollection();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              child: Icon(
                Amicons.iconly_search_fill,
                size: 72,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No memories yet',
              style: AppType.h3.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add your first ticket to search through them',
              style: AppType.small.copyWith(
                color: AppColors.textTertiary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── No search results ──────────────────────────────────────────
class _NoResults extends StatelessWidget {
  final String query;
  const _NoResults({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(40, 0, 40, 40),
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
                size: 26,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: AppType.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try a different search term',
              style: AppType.small.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ NOTCHED SHEET CLIPPER ════════════════════════════════════════
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
