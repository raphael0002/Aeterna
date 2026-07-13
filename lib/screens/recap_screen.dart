import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../data/ticket_store.dart';
import '../models/recap.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';

class RecapScreen extends StatefulWidget {
  final TicketStore store;
  final int year;

  const RecapScreen({super.key, required this.store, required this.year});

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  final _pc = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recap = buildRecap(widget.store.tickets, widget.year);

    if (recap.isEmpty) {
      return _EmptyRecap(year: widget.year);
    }

    final cat = recap.topCategory;
    final pages = <Widget>[
      _StoryPage(
        bg: AppColors.primary,
        eyebrow: '${widget.year} IN STUBS',
        big: '${recap.total}',
        caption: recap.total == 1 ? 'memory collected' : 'memories collected',
      ),
      _CategoryPage(
        bg: cat?.color ?? AppColors.catTravel,
        category: cat,
        count: recap.topCategoryCount,
      ),
      _VenuePage(venue: recap.topVenue),
      _MemorablePage(ticket: recap.mostMemorable),
      _MonthsPage(byMonth: recap.byMonth),
      _ClosingPage(
        year: widget.year,
        total: recap.total,
        onDone: () => Navigator.of(context).pop(),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pc,
            scrollDirection: Axis.vertical,
            onPageChanged: (i) {
              HapticFeedback.selectionClick();
              setState(() => _page = i);
            },
            children: pages,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ProgressBars(count: pages.length, index: _page),
            ),
          ),
          Positioned(
            right: 8,
            top: MediaQuery.of(context).padding.top + 40,
            child: _CloseButton(onTap: () => Navigator.of(context).pop()),
          ),
        ],
      ),
    );
  }
}

class _EmptyRecap extends StatelessWidget {
  final int year;
  const _EmptyRecap({required this.year});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 40,
              child: _CloseButton(onTap: () => Navigator.pop(context)),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No memories in $year yet',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start collecting stubs to\nunlock your recap.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress bars ─────────────────────────────────────────────────
class _ProgressBars extends StatelessWidget {
  final int count;
  final int index;
  const _ProgressBars({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(count, (i) {
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: i <= index ? 0.95 : 0.28),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.close_rounded, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ─── Base story page ───────────────────────────────────────────────
class _StoryPage extends StatelessWidget {
  final Color bg;
  final String eyebrow;
  final String big;
  final String caption;

  const _StoryPage({
    required this.bg,
    required this.eyebrow,
    required this.big,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: monoStyle(
              size: 12,
              color: Colors.white.withValues(alpha: 0.8),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              big,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 120,
                height: 0.95,
                fontWeight: FontWeight.w800,
                letterSpacing: -3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            caption,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          const Spacer(),
          _SwipeHint(),
        ],
      ),
    );
  }
}

// ─── Category page ─────────────────────────────────────────────────
class _CategoryPage extends StatelessWidget {
  final Color bg;
  final TicketCategory? category;
  final int count;

  const _CategoryPage({
    required this.bg,
    required this.category,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR TOP CATEGORY',
            style: monoStyle(
              size: 12,
              color: Colors.white.withValues(alpha: 0.8),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 24),
          if (category != null)
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(category!.icon, color: Colors.white, size: 52),
            ),
          const SizedBox(height: 24),
          Text(
            category?.label ?? '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 56,
              height: 1,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category == null
                ? 'No category winner yet'
                : '$count ${count == 1 ? "event" : "events"} this year',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _SwipeHint(),
        ],
      ),
    );
  }
}

// ─── Venue page ────────────────────────────────────────────────────
class _VenuePage extends StatelessWidget {
  final String? venue;
  const _VenuePage({required this.venue});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.catTravel,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR HOME BASE',
            style: monoStyle(
              size: 12,
              color: Colors.white.withValues(alpha: 0.8),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.place_rounded, color: Colors.white, size: 48),
          const SizedBox(height: 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              venue ?? 'Nowhere yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: venue != null && venue!.length > 15 ? 40 : 56,
                height: 1.05,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            venue == null
                ? 'Add venues to your tickets'
                : 'Your most-visited place',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          _SwipeHint(),
        ],
      ),
    );
  }
}

// ─── Memorable page ────────────────────────────────────────────────
class _MemorablePage extends StatelessWidget {
  final Ticket? ticket;
  const _MemorablePage({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final t = ticket;
    return Container(
      color: AppColors.catMilestone,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MOST MEMORABLE',
            style: monoStyle(
              size: 12,
              color: Colors.white.withValues(alpha: 0.85),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 20),
          if (t != null && t.rating > 0)
            Row(
              children: List.generate(t.rating, (_) {
                return const Padding(
                  padding: EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                );
              }),
            ),
          const SizedBox(height: 20),
          Text(
            t?.title ?? '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              height: 1.05,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          if (t != null && t.venue.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t.venue,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          const Spacer(),
          _SwipeHint(),
        ],
      ),
    );
  }
}

// ─── Months bar chart ──────────────────────────────────────────────
class _MonthsPage extends StatelessWidget {
  final Map<int, int> byMonth;
  const _MonthsPage({required this.byMonth});

  @override
  Widget build(BuildContext context) {
    final maxCount = byMonth.values.fold<int>(1, (m, v) => v > m ? v : m);
    final total = byMonth.values.fold<int>(0, (a, b) => a + b);

    return Container(
      color: AppColors.textPrimary,
      padding: const EdgeInsets.fromLTRB(32, 100, 32, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'YOUR RHYTHM',
            style: monoStyle(
              size: 12,
              color: Colors.white.withValues(alpha: 0.8),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.6),
          ),
          const SizedBox(height: 20),
          Text(
            '$total moments',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 44,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'across the year',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(12, (i) {
                final m = i + 1;
                final c = byMonth[m] ?? 0;
                final barH = 8.0 + (c / maxCount) * 170;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (c > 0)
                          Text(
                            '$c',
                            style: monoStyle(
                              size: 10,
                              color: Colors.white.withValues(alpha: 0.9),
                              weight: FontWeight.w700,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 400 + i * 50),
                          curve: Curves.easeOutCubic,
                          height: barH,
                          decoration: BoxDecoration(
                            color: c == 0
                                ? Colors.white.withValues(alpha: 0.12)
                                : AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          DateFormat('MMM').format(DateTime(2000, m))[0],
                          style: monoStyle(
                            size: 10,
                            color: Colors.white.withValues(alpha: 0.55),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Spacer(),
          _SwipeHint(color: Colors.white),
        ],
      ),
    );
  }
}

// ─── Closing page ──────────────────────────────────────────────────
class _ClosingPage extends StatelessWidget {
  final int year;
  final int total;
  final VoidCallback onDone;

  const _ClosingPage({
    required this.year,
    required this.total,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "That's a wrap.",
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You captured $total ${total == 1 ? "memory" : "memories"}\nin $year. Keep collecting.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: onDone,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: Text(
              'Back to my wallet',
              style: AppType.button.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Swipe hint ────────────────────────────────────────────────────
class _SwipeHint extends StatelessWidget {
  final Color color;
  const _SwipeHint({this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.keyboard_arrow_up_rounded,
            color: color.withValues(alpha: 0.7),
            size: 20,
          ),
          Text(
            'Swipe up',
            style: monoStyle(
              size: 10,
              color: color.withValues(alpha: 0.7),
              weight: FontWeight.w700,
            ).copyWith(letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}
