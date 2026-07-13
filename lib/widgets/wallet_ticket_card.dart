import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/ticket.dart';
import '../theme/app_theme.dart';

/// Wallet list card — boarding-pass aesthetic adapted to Aeterna data.
///
/// Layout:
///   ┌──────────────────────────────────────────┐
///   │ [icon] CATEGORY LABEL         [★ badge]  │
///   │                                          │
///   │  9:10 PM  o---✈---o  2:50 PM             │
///   │  DATE     duration    SAVED DATE         │
///   │ ╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌ │
///   │  [icon] Venue name         RATING/★★★★★  │
///   └──────────────────────────────────────────┘
class WalletTicketCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onTap;

  const WalletTicketCard({super.key, required this.ticket, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: CustomPaint(
          painter: _CardBgPainter(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(ticket: ticket),
                const SizedBox(height: 18),
                _JourneyRow(ticket: ticket),
                const SizedBox(height: 18),
                const _DashedLine(),
                const SizedBox(height: 14),
                _Footer(ticket: ticket),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card background with side notches ────────────────────────────────
class _CardBgPainter extends CustomPainter {
  static const double _radius = 22;
  static const double _notchRadius = 10;
  static const double _footerFromBottom = 52;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final notchY = h - _footerFromBottom;

    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    final left = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, notchY), radius: _notchRadius),
      );
    final right = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w, notchY), radius: _notchRadius),
      );

    final result = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, base, left),
      right,
    );

    canvas.drawShadow(result, const Color(0x1F3C2814), 0, false);
    canvas.drawPath(result, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CardBgPainter old) => false;
}

// ─── Header: category icon + label + status badge ────────────────────
class _Header extends StatelessWidget {
  final Ticket ticket;
  const _Header({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final cat = ticket.category;
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: cat.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(cat.icon, color: cat.color, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            ticket.ticketNumber.replaceAll('#', 'MT '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        _StatusBadge(ticket: ticket),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Ticket ticket;
  const _StatusBadge({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = _statusFor(ticket);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppType.small.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  (String, Color, Color) _statusFor(Ticket t) {
    if (t.favorite) {
      return ('★ Favorite', const Color(0xFFFDF4E4), const Color(0xFFB45309));
    }
    if (t.rating >= 4) {
      return ('The best', const Color(0xFFE3F1F0), const Color(0xFF2E8B87));
    }
    final daysAgo = DateTime.now().difference(t.date).inDays;
    if (daysAgo <= 7) {
      return ('Recent', const Color(0xFFEDF2E9), const Color(0xFF4E8752));
    }
    return (t.category.label, t.category.bg, t.category.color);
  }
}

// ─── Journey row: time — icon path — time ────────────────────────────
class _JourneyRow extends StatelessWidget {
  final Ticket ticket;
  const _JourneyRow({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final startTime = DateFormat('h:mm a').format(ticket.date);
    final startDate = DateFormat('d MMMM, yyyy').format(ticket.date);
    final endTime = DateFormat('h:mm a').format(ticket.createdAt);
    final endDate = DateFormat('d MMMM, yyyy').format(ticket.createdAt);
    final duration = _formatDuration(ticket.createdAt.difference(ticket.date));

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              startTime,
              style: AppType.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            Expanded(child: _PathVisual(icon: ticket.category.icon)),
            Text(
              endTime,
              style: AppType.h2.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text(
              startDate,
              style: AppType.small.copyWith(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              duration,
              style: AppType.small.copyWith(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              endDate,
              style: AppType.small.copyWith(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final abs = d.abs();
    if (abs.inDays > 0) {
      final days = abs.inDays;
      final hours = abs.inHours % 24;
      return hours > 0 ? '${days}d ${hours}h' : '${days}d';
    }
    if (abs.inHours > 0) {
      final h = abs.inHours;
      final m = abs.inMinutes % 60;
      return m > 0 ? '${h}h ${m}m' : '${h}h';
    }
    return '${abs.inMinutes}m';
  }
}

/// The dashed path with the category icon centered on it.
///  o╌╌╌╌╌╌ ✈ ╌╌╌╌╌╌o
class _PathVisual extends StatelessWidget {
  final IconData icon;
  const _PathVisual({required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Dashed line
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: CustomPaint(painter: _DashedHPainter()),
                  ),
                ),
                // Left dot
                Positioned(left: 0, child: _EndpointDot()),
                // Right dot
                Positioned(right: 0, child: _EndpointDot()),
                // Center icon
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Icon(icon, size: 16, color: AppColors.textTertiary),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _EndpointDot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.textTertiary, width: 1.4),
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
      ..color = AppColors.textTertiary.withValues(alpha: 0.55)
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

// ─── Dashed horizontal divider between body and footer ────────────────
class _DashedLine extends StatelessWidget {
  const _DashedLine();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedDividerPainter()),
    );
  }
}

class _DashedDividerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dash = 4.0, gap = 4.0;
    final paint = Paint()
      ..color = AppColors.perforation
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dash, 0), paint);
      x += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _DashedDividerPainter old) => false;
}

// ─── Footer: venue on the left, rating stars on the right ─────────────
class _Footer extends StatelessWidget {
  final Ticket ticket;
  const _Footer({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final cat = ticket.category;
    final hasVenue = ticket.venue.trim().isNotEmpty;

    return Row(
      children: [
        Icon(
          hasVenue ? Icons.place_rounded : cat.icon,
          size: 18,
          color: cat.color,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            hasVenue ? ticket.venue : cat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.body.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        if (ticket.rating > 0)
          _RatingDisplay(rating: ticket.rating, color: cat.color)
        else
          Text(
            'No rating',
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

class _RatingDisplay extends StatelessWidget {
  final int rating;
  final Color color;
  const _RatingDisplay({required this.rating, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$rating',
          style: AppType.title.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.star_rounded, size: 18, color: color),
      ],
    );
  }
}
