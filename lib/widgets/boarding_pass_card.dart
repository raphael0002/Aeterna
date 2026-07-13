import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/ticket.dart';
import '../theme/app_theme.dart';

/// White boarding-pass card with two circular side notches near the bottom.
/// Fully responsive: scales its typography and spacing to fit any parent size.
class BoardingPassCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback? onSecondaryAction;
  final String? secondaryLabel;

  const BoardingPassCard({
    super.key,
    required this.ticket,
    this.onSecondaryAction,
    this.secondaryLabel,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive scaling based on available height
        final h = constraints.maxHeight;
        final w = constraints.maxWidth;

        // "compact" mode when the card is short (small phones / landscape)
        final compact = h < 360;
        final tight = h < 300;

        // Space taken by the wallet footer below the perforation (~62px)
        final footerH = tight ? 44.0 : 56.0;

        return CustomPaint(
          painter: _BoardingPassBgPainter(footerHeight: footerH),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              compact ? 14 : 18,
              16,
              compact ? 10 : 14,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(ticket: ticket, compact: compact),
                SizedBox(height: compact ? 8 : 12),
                const _HairlineDivider(),
                SizedBox(height: compact ? 10 : 14),

                // ── Two big blocks (departure/arrival) ────────────
                Flexible(
                  flex: 5,
                  child: _DepartureArrival(ticket: ticket, compact: compact),
                ),
                SizedBox(height: compact ? 8 : 10),

                // ── Three small blocks (seats/terminal/gate) ──────
                Flexible(
                  flex: 4,
                  child: _MetaTriplet(
                    ticket: ticket,
                    compact: compact,
                    width: w,
                  ),
                ),

                const Spacer(),

                const _DashedLine(),
                SizedBox(height: compact ? 8 : 12),

                // ── Wallet footer ─────────────────────────────────
                if (secondaryLabel != null)
                  SizedBox(
                    height: compact ? 28 : 34,
                    child: Center(
                      child: InkWell(
                        onTap: onSecondaryAction,
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  secondaryLabel!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppType.body.copyWith(
                                    color: AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: compact ? 14 : 15,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '💳',
                                style: TextStyle(fontSize: compact ? 16 : 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Rounded rect with two circular notches on the sides at footer level.
class _BoardingPassBgPainter extends CustomPainter {
  final double footerHeight;
  static const double _radius = 22;
  static const double _notchRadius = 12;

  _BoardingPassBgPainter({required this.footerHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final notchY = h - footerHeight;

    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    final leftNotch = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(0, notchY), radius: _notchRadius),
      );
    final rightNotch = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(w, notchY), radius: _notchRadius),
      );

    final result = Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, base, leftNotch),
      rightNotch,
    );

    canvas.drawShadow(result, const Color(0x333C2814), 12, false);
    canvas.drawPath(result, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _BoardingPassBgPainter old) =>
      old.footerHeight != footerHeight;
}

class _Header extends StatelessWidget {
  final Ticket ticket;
  final bool compact;
  const _Header({required this.ticket, required this.compact});

  @override
  Widget build(BuildContext context) {
    final iconBox = compact ? 34.0 : 40.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: iconBox,
          height: iconBox,
          decoration: BoxDecoration(
            color: ticket.category.bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            ticket.category.icon,
            color: ticket.category.color,
            size: compact ? 18 : 20,
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
                style: AppType.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: compact ? 15 : 16,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                ticket.ticketNumber.replaceAll('#', 'MU '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppType.small.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: compact ? 12 : 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _rightPrimary(ticket),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 15 : 16,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _rightSecondary(ticket),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.small.copyWith(
                color: AppColors.textTertiary,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _rightPrimary(Ticket t) =>
      t.rating > 0 ? '${t.rating} stars' : '1 seat';
  String _rightSecondary(Ticket t) => t.category.label;
}

class _DepartureArrival extends StatelessWidget {
  final Ticket ticket;
  final bool compact;
  const _DepartureArrival({required this.ticket, required this.compact});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(ticket.date);
    final dateStr = DateFormat('d MMMM, yyyy').format(ticket.date);
    final savedTime = DateFormat('h:mm a').format(ticket.createdAt);
    final savedDate = DateFormat('d MMMM, yyyy').format(ticket.createdAt);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _BigBlock(
            label: 'Departure',
            value: timeStr,
            sub: dateStr,
            compact: compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BigBlock(
            label: 'Arrival',
            value: savedTime,
            sub: savedDate,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _BigBlock extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final bool compact;
  const _BigBlock({
    required this.label,
    required this.value,
    required this.sub,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.small.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: compact ? 12 : 13,
            ),
          ),
          SizedBox(height: compact ? 4 : 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppType.h2.copyWith(
                color: AppColors.textPrimary,
                fontSize: compact ? 18 : 22,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
          ),
          SizedBox(height: compact ? 2 : 4),
          Text(
            sub,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTriplet extends StatelessWidget {
  final Ticket ticket;
  final bool compact;
  final double width;
  const _MetaTriplet({
    required this.ticket,
    required this.compact,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _SmallBlock(
            value: '${ticket.rating}, ${ticket.rating}',
            label: 'Seats',
            compact: compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallBlock(
            value: 'T${(ticket.id.hashCode.abs() % 9) + 1}',
            label: 'Terminal',
            compact: compact,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SmallBlock(
            value: '${(ticket.id.hashCode.abs() % 900) + 100}',
            label: 'Gate',
            compact: compact,
          ),
        ),
      ],
    );
  }
}

class _SmallBlock extends StatelessWidget {
  final String value;
  final String label;
  final bool compact;
  const _SmallBlock({
    required this.value,
    required this.label,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 12,
        vertical: compact ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EEE5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppType.title.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 15 : 18,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontSize: compact ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _HairlineDivider extends StatelessWidget {
  const _HairlineDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.borderSubtle);
}

class _DashedLine extends StatelessWidget {
  const _DashedLine();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
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
  bool shouldRepaint(covariant _DashedLinePainter old) => false;
}
