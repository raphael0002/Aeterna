import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/ticket.dart';
import '../providers/filter_providers.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/world_map_backdrop.dart';

// Deeper cream for sheet, so white cards visually lift
const _kSheetBg = Color(0xFFF0EAE0);

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selected;
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _selected = _stripDate(DateTime.now());
    _weekStart = _weekStartFor(_selected);
  }

  DateTime _stripDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _weekStartFor(DateTime d) {
    final s = _stripDate(d);
    return s.subtract(Duration(days: s.weekday - 1));
  }

  void _selectDay(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() {
      _selected = _stripDate(day);
      _weekStart = _weekStartFor(_selected);
    });
  }

  void _prevWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _weekStart = _weekStart.subtract(const Duration(days: 7));
    });
  }

  void _nextWeek() {
    HapticFeedback.selectionClick();
    setState(() {
      _weekStart = _weekStart.add(const Duration(days: 7));
    });
  }

  void _goToToday() {
    HapticFeedback.mediumImpact();
    setState(() {
      _selected = _stripDate(DateTime.now());
      _weekStart = _weekStartFor(_selected);
    });
  }

  Future<void> _openMonthPicker() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selected = _stripDate(picked);
        _weekStart = _weekStartFor(_selected);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(ticketStoreProvider);
    final categoryFilter = ref.watch(categoryFilterProvider);
    final allTickets = store.tickets;

    final byDay = <DateTime, List<Ticket>>{};
    for (final t in allTickets) {
      if (categoryFilter != null && t.category != categoryFilter) continue;
      final key = _stripDate(t.date);
      byDay.putIfAbsent(key, () => []).add(t);
    }

    final selectedTickets = byDay[_selected] ?? [];
    final monthCount = allTickets
        .where(
          (t) =>
              t.date.year == _selected.year && t.date.month == _selected.month,
        )
        .length;

    final isTodaySelected =
        _isSameDay(_selected, DateTime.now()) &&
        _weekStart == _weekStartFor(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final topInset = mq.padding.top;
          final screenH = constraints.maxHeight;
          final heroH = (screenH * 0.19).clamp(155.0, 195.0);

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
                  scale: 3,
                  offsetY: -0.9,
                ),
              ),

              // Hero
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: heroH,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: _Hero(
                    year: _selected.year,
                    monthName: DateFormat('MMMM').format(_selected),
                    monthCount: monthCount,
                    isTodaySelected: isTodaySelected,
                    onPrev: _prevWeek,
                    onNext: _nextWeek,
                    onToday: _goToToday,
                    onMonthTap: _openMonthPicker,
                  ),
                ),
              ),

              // Sheet
              Positioned(
                top: heroH,
                left: 0,
                right: 0,
                bottom: 0,
                child: ClipPath(
                  clipper: const _SheetTopClipper(),
                  child: Container(
                    color: _kSheetBg, // ← deeper cream, cards will pop
                    child: Column(
                      children: [
                        const SizedBox(height: 26),
                        _DateStrip(
                          weekStart: _weekStart,
                          selected: _selected,
                          byDay: byDay,
                          onSelect: _selectDay,
                        ),
                        const SizedBox(height: 16),
                        _SectionHeader(
                          date: _selected,
                          count: selectedTickets.length,
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: selectedTickets.isEmpty
                              ? _EmptyDay(onAdd: () => context.push('/new'))
                              : ListView.separated(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.fromLTRB(
                                    20,
                                    4,
                                    20,
                                    120,
                                  ),
                                  itemCount: selectedTickets.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (ctx, i) => CompactTicketRow(
                                    ticket: selectedTickets[i],
                                    onTap: () => context.push(
                                      '/ticket/${selectedTickets[i].id}',
                                    ),
                                  ),
                                ),
                        ),
                      ],
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

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ═══ HERO ═══════════════════════════════════════════════════════════
class _Hero extends StatelessWidget {
  final int year;
  final String monthName;
  final int monthCount;
  final bool isTodaySelected;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onMonthTap;

  const _Hero({
    required this.year,
    required this.monthName,
    required this.monthCount,
    required this.isTodaySelected,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
    required this.onMonthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _CircleBtn(icon: Icons.chevron_left_rounded, onTap: onPrev),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: onMonthTap,
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$monthName $year',
                          style: AppType.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CircleBtn(icon: Icons.chevron_right_rounded, onTap: onNext),
            ],
          ),
          const Spacer(),

          // ── "Jump to today" as a proper button + count ─────
          Row(
            children: [
              _TodayButton(onTap: onToday, highlighted: !isTodaySelected),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$monthCount ${monthCount == 1 ? "stub" : "stubs"}',
                  style: AppType.small.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// ─── Today button ──────────────────────────────────────────────────
class _TodayButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool highlighted;

  const _TodayButton({required this.onTap, required this.highlighted});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: highlighted ? Colors.white : Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.today_rounded,
                size: 15,
                color: highlighted ? AppColors.primary : Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                'Jump to today',
                style: AppType.small.copyWith(
                  color: highlighted ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══ DATE STRIP ══════════════════════════════════════════════════════
class _DateStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selected;
  final Map<DateTime, List<Ticket>> byDay;
  final ValueChanged<DateTime> onSelect;

  const _DateStrip({
    required this.weekStart,
    required this.selected,
    required this.byDay,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 7,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final day = weekStart.add(Duration(days: i));
          final key = DateTime(day.year, day.month, day.day);
          final tickets = byDay[key] ?? [];
          return _DateCell(
            day: day,
            selected: _isSameDay(day, selected),
            isToday: _isSameDay(day, DateTime.now()),
            tickets: tickets,
            onTap: () => onSelect(day),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _DateCell extends StatelessWidget {
  final DateTime day;
  final bool selected;
  final bool isToday;
  final List<Ticket> tickets;
  final VoidCallback onTap;

  const _DateCell({
    required this.day,
    required this.selected,
    required this.isToday,
    required this.tickets,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasEvents = tickets.isNotEmpty;

    // ── Color logic: distinct backgrounds by state ──
    Color bg;
    if (selected) {
      bg = AppColors.primary; // Selected = primary orange
    } else if (hasEvents) {
      bg = Colors.white; // Has events = white (stands out on cream sheet)
    } else {
      bg = Colors.white.withValues(alpha: 0.55); // Empty = translucent
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: 62,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 4,
                child: selected
                    ? Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                    : hasEvents
                    ? _CategoryDots(tickets: tickets)
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 6),
              Text(
                '${day.day}',
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                  fontSize: 20,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('MMM').format(day),
                style: monoStyle(
                  size: 10,
                  color: selected
                      ? Colors.white.withValues(alpha: 0.9)
                      : AppColors.textTertiary,
                  weight: FontWeight.w700,
                ),
              ),
              if (isToday && !selected) ...[
                const SizedBox(height: 3),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryDots extends StatelessWidget {
  final List<Ticket> tickets;
  const _CategoryDots({required this.tickets});

  @override
  Widget build(BuildContext context) {
    final categories = tickets.map((t) => t.category).toSet().take(3).toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final c in categories) ...[
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 2),
        ],
      ],
    );
  }
}

// ═══ SECTION HEADER ══════════════════════════════════════════════════
class _SectionHeader extends StatelessWidget {
  final DateTime date;
  final int count;

  const _SectionHeader({required this.date, required this.count});

  @override
  Widget build(BuildContext context) {
    final isToday = _isSameDay(date, DateTime.now());
    final label = isToday
        ? 'Today'
        : _isSameDay(date, DateTime.now().add(const Duration(days: 1)))
        ? 'Tomorrow'
        : _isSameDay(date, DateTime.now().subtract(const Duration(days: 1)))
        ? 'Yesterday'
        : DateFormat('EEEE').format(date);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppType.h2.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('MMMM d, yyyy').format(date),
                  style: AppType.small.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count ${count == 1 ? "stub" : "stubs"}',
                style: AppType.small.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ═══ EMPTY DAY ═══════════════════════════════════════════════════════
class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 72),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 72,
              height: 72,
              child: const Icon(
                Icons.event_note_rounded,
                color: AppColors.primary,
                size: 72,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Nothing on this day',
              style: AppType.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap the + button to add a memory',
              style: AppType.body.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ SHEET CLIPPER ═══════════════════════════════════════════════════
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

// ═══ COMPACT TICKET ROW (shared, exported) ═════════════════════════
class CompactTicketRow extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;

  const CompactTicketRow({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: ticket.category.bg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ticket.category.icon,
                          size: 12,
                          color: ticket.category.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.category.label,
                          style: AppType.small.copyWith(
                            color: ticket.category.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ticket.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.body.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (ticket.favorite)
                    const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFFFC94A),
                      size: 16,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _TimeBlock(
                    time: DateFormat('h:mm a').format(ticket.date),
                    label: ticket.venue.isEmpty ? 'Event' : ticket.venue,
                  ),
                  Expanded(
                    child: _PathVisual(
                      icon: ticket.category.icon,
                      color: ticket.category.color,
                    ),
                  ),
                  _TimeBlock(
                    time: DateFormat('h:mm a').format(ticket.createdAt),
                    label: 'Saved',
                    alignEnd: true,
                  ),
                ],
              ),
              if (ticket.rating > 0) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.borderSubtle),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 2),
                          child: Icon(
                            i < ticket.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            size: 13,
                            color: i < ticket.rating
                                ? ticket.category.color
                                : AppColors.textTertiary,
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    Text(
                      ticket.ticketNumber,
                      style: monoStyle(size: 11, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeBlock extends StatelessWidget {
  final String time;
  final String label;
  final bool alignEnd;

  const _TimeBlock({
    required this.time,
    required this.label,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          time,
          style: AppType.h3.copyWith(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 100,
          child: Text(
            label,
            textAlign: alignEnd ? TextAlign.end : TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class _PathVisual extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _PathVisual({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: CustomPaint(painter: _DashedHPainter()),
              ),
            ),
            Positioned(left: 0, child: _Dot(color: color)),
            Positioned(right: 0, child: _Dot(color: color)),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Icon(icon, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
        color: Colors.white,
      ),
    );
  }
}

class _DashedHPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0, gap = 4.0;
    final paint = Paint()
      ..color = AppColors.textTertiary.withValues(alpha: 0.5)
      ..strokeWidth = 1.2;
    double x = 0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dash, y), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedHPainter old) => false;
}
