import 'dart:io';

import 'package:amicons/amicons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/ticket.dart';
import '../models/ticket_template.dart';
import '../theme/app_theme.dart';
import 'rating_tickets.dart';

/// Size/role variants — genuinely different layouts, not just styling.
/// - [compact]  HORIZONTAL ticket (square photo | vertical tear | stub) — lists.
/// - [standard] VERTICAL ticket (photo → tear → stub) — previews.
/// - [feature]  Tall vertical ticket, photo fills + full stub — detail hero.
enum MemoryCardVariant { compact, standard, feature }

const _shadow = Color(0x1F3C2814);

/// Photo-forward memory ticket with a real ticket silhouette (side notches +
/// perforation). Template-aware: Classic / Minimal / Accent / Mono each render
/// structurally differently, not just recolored.
class MemoryTicketCard extends StatelessWidget {
  final Ticket ticket;
  final MemoryCardVariant variant;
  final VoidCallback? onTap;

  const MemoryTicketCard({
    super.key,
    required this.ticket,
    this.variant = MemoryCardVariant.standard,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = ticket.template.accent(ticket.category.color);
    final Widget card = switch (variant) {
      MemoryCardVariant.compact => _CompactTicket(ticket: ticket, accent: accent),
      MemoryCardVariant.standard =>
        _VerticalTicket(ticket: ticket, accent: accent, feature: false),
      MemoryCardVariant.feature =>
        _VerticalTicket(ticket: ticket, accent: accent, feature: true),
    };

    if (onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: card,
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// COMPACT — horizontal ticket for list rows
// ══════════════════════════════════════════════════════════════════
class _CompactTicket extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  const _CompactTicket({required this.ticket, required this.accent});

  static const double _h = 108;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _h,
      child: PhysicalShape(
        clipper: _TicketClipper(vertical: false, tearAt: (s) => s.height + 7),
        clipBehavior: Clip.antiAlias,
        color: AppColors.surface,
        elevation: 4,
        shadowColor: _shadow,
        child: Row(
          children: [
            // Square photo
            SizedBox(
              width: _h,
              height: _h,
              child: _Photo(ticket: ticket, accent: accent, compact: true),
            ),
            // Vertical perforation
            const SizedBox(
              width: 14,
              child: CustomPaint(
                painter: _DotsPainter(vertical: true),
                child: SizedBox.expand(),
              ),
            ),
            // Stub
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(ticket.category.icon, size: 13, color: accent),
                        const SizedBox(width: 5),
                        Text(
                          ticket.category.label.toUpperCase(),
                          style: monoStyle(
                            size: 10,
                            color: accent,
                            weight: FontWeight.w700,
                          ).copyWith(letterSpacing: 1),
                        ),
                        const Spacer(),
                        if (ticket.favorite)
                          const Icon(Amicons.iconly_star_fill,
                              size: 13, color: Color(0xFFE8A93C)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ticket.title.isEmpty ? 'Untitled memory' : ticket.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppType.title.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _MetaRow(ticket: ticket, small: true),
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

// ══════════════════════════════════════════════════════════════════
// VERTICAL — standard preview + feature detail
// ══════════════════════════════════════════════════════════════════
class _VerticalTicket extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  final bool feature;
  const _VerticalTicket({
    required this.ticket,
    required this.accent,
    required this.feature,
  });

  static const double _photoAspect = 3 / 2; // standard photo w:h
  static const double _featureStubH = 156;

  @override
  Widget build(BuildContext context) {
    final tpl = ticket.template;
    final stub = _Stub(ticket: ticket, accent: accent, feature: feature, tpl: tpl);

    final clipper = _TicketClipper(
      vertical: true,
      tearAt: feature
          ? (s) => s.height - _featureStubH - 7
          : (s) => s.width / _photoAspect + 7,
    );

    final content = Column(
      mainAxisSize: feature ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (feature)
          Expanded(child: _Photo(ticket: ticket, accent: accent, compact: false))
        else
          AspectRatio(
            aspectRatio: _photoAspect,
            child: _Photo(ticket: ticket, accent: accent, compact: false),
          ),
        SizedBox(
          height: 14,
          child: CustomPaint(
            painter: const _DotsPainter(vertical: false),
            child: const SizedBox.expand(),
          ),
        ),
        if (feature) SizedBox(height: _featureStubH, child: stub) else stub,
      ],
    );

    final card = PhysicalShape(
      clipper: clipper,
      clipBehavior: Clip.antiAlias,
      color: AppColors.surface,
      elevation: 5,
      shadowColor: _shadow,
      child: content,
    );

    // Mono template: industrial dashed outline over the ticket.
    if (tpl == TicketTemplate.mono) {
      return CustomPaint(
        foregroundPainter: _DashedBorderPainter(radius: 20),
        child: card,
      );
    }
    return card;
  }
}

// ─── Stub (below the tear) — template-differentiated ─────────────────
class _Stub extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  final bool feature;
  final TicketTemplate tpl;
  const _Stub({
    required this.ticket,
    required this.accent,
    required this.feature,
    required this.tpl,
  });

  @override
  Widget build(BuildContext context) {
    final mono = tpl.mono;
    final minimal = tpl == TicketTemplate.minimal;
    final title = ticket.title.isEmpty ? 'Untitled memory' : ticket.title;

    final head = tpl == TicketTemplate.accent
        // Accent: solid category band behind the title.
        ? Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.title.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        : Text(
            title,
            maxLines: feature ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: (mono
                    ? monoStyle(size: 16, weight: FontWeight.w700)
                    : AppType.title)
                .copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          );

    final footer = minimal
        ? _MinimalFooter(ticket: ticket, accent: accent)
        : _BarcodeBlock(ticket: ticket, accent: accent, big: mono);

    // Feature stub is a fixed-height box → Column can push the footer to the
    // bottom with a Spacer. Standard stub is content-sized (min) → no Spacer.
    final children = <Widget>[
      head,
      const SizedBox(height: 7),
      _MetaRow(ticket: ticket, small: false),
      if (feature) const Spacer() else const SizedBox(height: 12),
      const _StubDivider(),
      const SizedBox(height: 10),
      footer,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: feature ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _StubDivider extends StatelessWidget {
  const _StubDivider();
  @override
  Widget build(BuildContext context) =>
      Container(height: 1, color: AppColors.borderSubtle);
}

class _MinimalFooter extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  const _MinimalFooter({required this.ticket, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          ticket.ticketNumber.replaceAll('#', 'No. '),
          style: monoStyle(size: 12, color: AppColors.textTertiary),
        ),
        const Spacer(),
        if (ticket.rating > 0)
          RatingTickets(rating: ticket.rating, size: 13, color: accent),
      ],
    );
  }
}

class _BarcodeBlock extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  final bool big;
  const _BarcodeBlock({
    required this.ticket,
    required this.accent,
    required this.big,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              ticket.ticketNumber.replaceAll('#', 'No. '),
              style: monoStyle(
                size: 12,
                color: AppColors.textTertiary,
                weight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (ticket.rating > 0)
              RatingTickets(rating: ticket.rating, size: 13, color: accent),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: big ? 34 : 26,
          child: CustomPaint(
            painter: _BarcodePainter(seed: ticket.id.hashCode),
            child: const SizedBox.expand(),
          ),
        ),
      ],
    );
  }
}

// ─── Hero photo (or category placeholder) with overlays ──────────────
class _Photo extends StatelessWidget {
  final Ticket ticket;
  final Color accent;
  final bool compact;
  const _Photo({
    required this.ticket,
    required this.accent,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        ticket.hasImage && !kIsWeb && File(ticket.imagePath!).existsSync();

    final Widget base = hasImage
        ? Image.file(
            File(ticket.imagePath!),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          )
        : Container(
            color: accent.withValues(alpha: 0.10),
            alignment: Alignment.center,
            child: Icon(ticket.category.icon,
                size: compact ? 30 : 44, color: accent.withValues(alpha: 0.7)),
          );

    if (compact) return base; // chips shown in the stub for compact

    return Stack(
      fit: StackFit.expand,
      children: [
        base,
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.center,
                colors: [Color(0x33000000), Color(0x00000000)],
              ),
            ),
          ),
        ),
        Positioned(top: 10, left: 10, child: _CategoryChip(ticket: ticket)),
        if (ticket.favorite)
          const Positioned(top: 10, right: 10, child: _FavoriteBadge()),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final Ticket ticket;
  const _CategoryChip({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ticket.category.icon, size: 13, color: ticket.category.color),
          const SizedBox(width: 5),
          Text(
            ticket.category.label,
            style: AppType.small.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteBadge extends StatelessWidget {
  const _FavoriteBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        shape: BoxShape.circle,
      ),
      child: const Icon(Amicons.iconly_star_fill,
          size: 15, color: Color(0xFFE8A93C)),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final Ticket ticket;
  final bool small;
  const _MetaRow({required this.ticket, required this.small});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('d MMM yyyy').format(ticket.date);
    final place = ticket.venue.trim();
    final style = AppType.small
        .copyWith(color: AppColors.textSecondary, fontSize: small ? 11.5 : 12);

    return Row(
      children: [
        Icon(Amicons.iconly_calendar, size: 13, color: AppColors.textTertiary),
        const SizedBox(width: 4),
        Text(date, style: style),
        if (place.isNotEmpty) ...[
          const SizedBox(width: 8),
          Icon(Amicons.iconly_location, size: 13, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(place,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
          ),
        ],
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Painters / clipper
// ══════════════════════════════════════════════════════════════════
class _TicketClipper extends CustomClipper<Path> {
  /// true → notches on left/right (horizontal tear line at y).
  /// false → notches on top/bottom (vertical tear line at x).
  final bool vertical;
  final double Function(Size) tearAt;
  static const double notchR = 11;
  static const double radius = 18;
  const _TicketClipper({required this.vertical, required this.tearAt});

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final t = tearAt(size);
    final Path n1, n2;
    if (vertical) {
      n1 = Path()..addOval(Rect.fromCircle(center: Offset(0, t), radius: notchR));
      n2 = Path()
        ..addOval(Rect.fromCircle(center: Offset(size.width, t), radius: notchR));
    } else {
      n1 = Path()..addOval(Rect.fromCircle(center: Offset(t, 0), radius: notchR));
      n2 = Path()
        ..addOval(Rect.fromCircle(center: Offset(t, size.height), radius: notchR));
    }
    return Path.combine(
      PathOperation.difference,
      Path.combine(PathOperation.difference, base, n1),
      n2,
    );
  }

  @override
  bool shouldReclip(covariant _TicketClipper old) => old.vertical != vertical;
}

class _DotsPainter extends CustomPainter {
  final bool vertical; // dots run vertically (compact) vs horizontally
  const _DotsPainter({required this.vertical});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.perforation;
    const r = 1.6, gap = 8.0;
    if (vertical) {
      final x = size.width / 2;
      double y = gap;
      while (y < size.height - gap) {
        canvas.drawCircle(Offset(x, y), r, paint);
        y += gap;
      }
    } else {
      final y = size.height / 2;
      double x = gap;
      while (x < size.width - gap) {
        canvas.drawCircle(Offset(x, y), r, paint);
        x += gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotsPainter old) => old.vertical != vertical;
}

class _BarcodePainter extends CustomPainter {
  final int seed;
  _BarcodePainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.textPrimary;
    var s = seed & 0x7fffffff;
    int next() => s = (s * 1103515245 + 12345) & 0x7fffffff;
    double x = 0;
    while (x < size.width) {
      final w = 1.0 + (next() % 4);
      final gap = 1.0 + (next() % 3);
      if (next() % 3 != 0) {
        canvas.drawRect(Rect.fromLTWH(x, 0, w, size.height), paint);
      }
      x += w + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _BarcodePainter old) => old.seed != seed;
}

/// Dashed rounded outline (Mono template).
class _DashedBorderPainter extends CustomPainter {
  final double radius;
  _DashedBorderPainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(3, 3, size.width - 6, size.height - 6),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final dashed = Path();
    const dash = 5.0, gap = 4.0;
    for (final metric in path.computeMetrics()) {
      double d = 0;
      while (d < metric.length) {
        dashed.addPath(metric.extractPath(d, d + dash), Offset.zero);
        d += dash + gap;
      }
    }
    canvas.drawPath(
      dashed,
      Paint()
        ..color = AppColors.borderStrong
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => false;
}
