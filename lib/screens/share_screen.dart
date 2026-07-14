import 'package:amicons/amicons.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../models/ticket.dart';
import '../theme/app_theme.dart';

enum SharePrivacy { stubOnly, stubPlusNote, full }

extension _SharePrivacyX on SharePrivacy {
  String get label => switch (this) {
    SharePrivacy.stubOnly => 'Stub only',
    SharePrivacy.stubPlusNote => 'With note',
    SharePrivacy.full => 'Full detail',
  };

  String get description => switch (this) {
    SharePrivacy.stubOnly => 'Just the essentials',
    SharePrivacy.stubPlusNote => 'Include your note',
    SharePrivacy.full => 'Everything: note, rating, venue',
  };

  IconData get icon => switch (this) {
    SharePrivacy.stubOnly => Amicons.iconly_lock_fill,
    SharePrivacy.stubPlusNote => Amicons.iconly_document_fill,
    SharePrivacy.full => Amicons.iconly_unlock_fill,
  };

  bool get showNote => this != SharePrivacy.stubOnly;
  bool get showExtras => this == SharePrivacy.full;
}

class ShareScreen extends StatefulWidget {
  final Ticket ticket;
  const ShareScreen({super.key, required this.ticket});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _cardKey = GlobalKey();
  SharePrivacy _privacy = SharePrivacy.stubOnly;
  bool _sharing = false;

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      await Future.delayed(const Duration(milliseconds: 50));

      final boundary =
          _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Could not find render boundary');
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw Exception('Could not render card');

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/stub_${widget.ticket.id}.png');
      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.ticket.title} — a memory from my collection',
        subject: 'Aeterna: ${widget.ticket.title}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(onBack: () => context.pop(), title: 'Share ticket'),

            // ── Preview ──────────────────────────────────
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  child: RepaintBoundary(
                    key: _cardKey,
                    child: _ShareCard(ticket: widget.ticket, privacy: _privacy),
                  ),
                ),
              ),
            ),

            // ── Bottom sheet ─────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x143C2814),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'PRIVACY',
                    style: monoStyle(
                      size: 11,
                      color: AppColors.textSecondary,
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (int i = 0; i < SharePrivacy.values.length; i++) ...[
                        Expanded(
                          child: _PrivacyOption(
                            option: SharePrivacy.values[i],
                            selected: _privacy == SharePrivacy.values[i],
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _privacy = SharePrivacy.values[i]);
                            },
                          ),
                        ),
                        if (i < SharePrivacy.values.length - 1)
                          const SizedBox(width: 8),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _sharing ? null : _share,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: _sharing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Amicons.iconly_send_fill, size: 18),
                      label: Text(
                        _sharing ? 'Preparing…' : 'Share as image',
                        style: AppType.button.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Top bar ───────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _TopBar({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onBack();
              },
              child: const SizedBox(
                width: 42,
                height: 42,
                child: Icon(
                  Amicons.iconly_arrow_left_2_fill,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppType.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 42),
        ],
      ),
    );
  }
}

// ─── Privacy option ────────────────────────────────────────────────
class _PrivacyOption extends StatelessWidget {
  final SharePrivacy option;
  final bool selected;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.12)
              : AppColors.surfaceInset,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              option.icon,
              size: 20,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 6),
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.small.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
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

// ─── Share card ────────────────────────────────────────────────────
class _ShareCard extends StatelessWidget {
  final Ticket ticket;
  final SharePrivacy privacy;

  const _ShareCard({required this.ticket, required this.privacy});

  @override
  Widget build(BuildContext context) {
    final path = ticket.imagePath;
    final hasImage = path != null && File(path).existsSync();

    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0x293C2814),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 5,
              child: hasImage
                  ? Image.file(
                      File(path),
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: ticket.category.bg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            ticket.category.icon,
                            color: ticket.category.color,
                            size: 15,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          ticket.category.label.toUpperCase(),
                          style: monoStyle(
                            size: 10,
                            color: ticket.category.color,
                            weight: FontWeight.w700,
                          ).copyWith(letterSpacing: 1.2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      ticket.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.1,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, yyyy').format(ticket.date) +
                          (privacy.showExtras && ticket.venue.isNotEmpty
                              ? ' · ${ticket.venue}'
                              : ''),
                      style: monoStyle(
                        size: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (privacy.showExtras && ticket.rating > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: List.generate(
                          ticket.rating,
                          (_) => Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              Amicons.iconly_star_fill,
                              size: 14,
                              color: ticket.category.color,
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (privacy.showNote && ticket.note.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Expanded(
                        child: Text(
                          ticket.note,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            height: 1.45,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceInset,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: QrImageView(
                            data: ticketDeepLink(ticket.id),
                            size: 40,
                            padding: EdgeInsets.zero,
                            backgroundColor: Colors.transparent,
                            eyeStyle: const QrEyeStyle(
                              color: AppColors.textPrimary,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aeterna',
                              style: AppType.small.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              ticket.ticketNumber,
                              style: monoStyle(
                                size: 10,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _placeholder() => Container(
    color: ticket.category.color.withValues(alpha: 0.08),
    child: Center(
      child: Icon(
        ticket.category.icon,
        size: 64,
        color: ticket.category.color.withValues(alpha: 0.5),
      ),
    ),
  );
}
