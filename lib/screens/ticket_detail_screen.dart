import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../models/ticket.dart';
import '../providers/ticket_store_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/boarding_pass_card.dart';
import '../widgets/qr_sheet.dart';
import '../widgets/world_map_backdrop.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(ticketStoreProvider);
    final ticket = store.byId(ticketId);

    if (ticket == null) {
      return Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ticket not found',
                style: AppType.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text(
                  'Go back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final mq = MediaQuery.of(context);
          final topInset = mq.padding.top;
          final screenH = constraints.maxHeight;

          // ── Layout budget ───────────────────────────────────────
          final topBarH = 42.0 + 8.0;
          final numberBlockH = (screenH * 0.09).clamp(56.0, 82.0);
          final indicatorH = 14.0 + 18.0;
          final topZoneH = topInset + topBarH + numberBlockH + indicatorH;

          final qrSheetH = (screenH * 0.36).clamp(240.0, 340.0);
          final cardZoneH = (screenH - topZoneH - qrSheetH).clamp(240.0, 500.0);

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
                height: topZoneH + cardZoneH + 20,
                child: const WorldMapBackdrop(
                  opacity: 0.8,
                  scale: 3.2,
                  offsetY: -0.9,
                  offsetX: -0.4,
                ),
              ),

              // ── Top zone ────────────────────────────────────────
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topZoneH,
                child: Padding(
                  padding: EdgeInsets.only(top: topInset),
                  child: Column(
                    children: [
                      _TopBar(ticket: ticket, ref: ref),
                      const SizedBox(height: 8),
                      Expanded(child: _HeroNumber(ticket: ticket)),
                      const SizedBox(height: 4),
                      const _PageIndicator(),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ),

              // ── Card ────────────────────────────────────────────
              Positioned(
                top: topZoneH,
                left: 0,
                right: 0,
                height: cardZoneH,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: BoardingPassCard(
                    ticket: ticket,
                    secondaryLabel: 'Add to Apple Wallet',
                    onSecondaryAction: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Wallet integration coming soon'),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // ── QR sheet ────────────────────────────────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: qrSheetH,
                child: QrSheet(
                  data: ticketDeepLink(ticket.id),
                  onExpand: () => _showQrFullscreen(context, ticket),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQrFullscreen(BuildContext context, Ticket ticket) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        insetPadding: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              QrImageView(
                data: ticketDeepLink(ticket.id),
                size: 280,
                padding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppColors.textPrimary,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                ticket.title,
                textAlign: TextAlign.center,
                style: AppType.h3.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                ticket.ticketNumber,
                style: monoStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══ TOP BAR ═══════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final Ticket ticket;
  final WidgetRef ref;

  const _TopBar({required this.ticket, required this.ref});

  Future<void> _toggleFavorite(BuildContext context) async {
    HapticFeedback.lightImpact();
    await ref
        .read(ticketStoreProvider)
        .setFavorite(ticket.id, !ticket.favorite);
  }

  void _openMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (ctx) => _MoreSheet(
        ticket: ticket,
        onEdit: () {
          Navigator.pop(ctx);
          context.push('/edit/${ticket.id}');
        },
        onShare: () {
          Navigator.pop(ctx);
          context.push('/share/${ticket.id}');
        },
        onDelete: () async {
          Navigator.pop(ctx);
          final confirmed = await _confirmDelete(context);
          if (confirmed == true && context.mounted) {
            await ref.read(ticketStoreProvider).delete(ticket.id);
            if (context.mounted) context.pop();
          }
        },
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete ticket?',
          style: AppType.h3.copyWith(color: AppColors.textPrimary),
        ),
        content: Text(
          'This memory will be permanently removed from your wallet. This action cannot be undone.',
          style: AppType.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          _SquareIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => context.pop(),
          ),
          Expanded(
            child: Center(
              child: Text(
                'Boarding pass',
                style: AppType.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // ── Favorite toggle (instant action) ────────────────
          _SquareIconButton(
            icon: ticket.favorite
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            iconColor: ticket.favorite ? const Color(0xFFFFC94A) : Colors.white,
            onTap: () => _toggleFavorite(context),
          ),
          const SizedBox(width: 6),
          // ── More menu (Edit / Delete / Share) ───────────────
          _SquareIconButton(
            icon: Icons.more_horiz_rounded,
            onTap: () => _openMoreMenu(context),
          ),
        ],
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;

  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
          child: Icon(icon, color: iconColor ?? Colors.white, size: 20),
        ),
      ),
    );
  }
}

// ═══ HERO NUMBER ═══════════════════════════════════════════════════
class _HeroNumber extends StatelessWidget {
  final Ticket ticket;
  const _HeroNumber({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('d MMM, yyyy').format(ticket.date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    letterSpacing: -0.5,
                    height: 1.05,
                  ),
                  children: [
                    TextSpan(
                      text: 'Nº ',
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    TextSpan(text: _formatNumber(ticket)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              dateStr,
              style: AppType.small.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(Ticket t) {
    final digits = t.ticketNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final seed = t.id.hashCode.abs().toString().padLeft(6, '0');
    final p1 = digits.padLeft(4, '0').substring(0, 4);
    final p2 = seed.substring(0, 4);
    final p3 = seed.substring(4, 6);
    return '$p1-$p2-$p3';
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 26,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ═══ MORE BOTTOM SHEET ═════════════════════════════════════════════
class _MoreSheet extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _MoreSheet({
    required this.ticket,
    required this.onEdit,
    required this.onShare,
    required this.onDelete,
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
            // Grabber
            Container(
              width: 40,
              height: 5,
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 8),

            // Header: category icon + title (compact context)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: ticket.category.bg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      ticket.category.icon,
                      size: 18,
                      color: ticket.category.color,
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
                        Text(
                          ticket.ticketNumber,
                          style: monoStyle(
                            size: 11,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const _SheetDivider(),

            _SheetTile(
              icon: Icons.edit_rounded,
              label: 'Edit ticket',
              subtitle: 'Update details, photo, or rating',
              onTap: onEdit,
              accent: true,
            ),
            const _SheetDivider(),
            _SheetTile(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              subtitle: 'Export ticket as an image',
              onTap: onShare,
            ),
            const _SheetDivider(),
            _SheetTile(
              icon: Icons.delete_outline_rounded,
              label: 'Delete ticket',
              subtitle: 'Permanently remove this memory',
              onTap: onDelete,
              destructive: true,
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
  final bool destructive;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.accent = false,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconBg = destructive
        ? AppColors.danger.withValues(alpha: 0.12)
        : accent
        ? AppColors.primary
        : AppColors.primaryFaint;
    final iconFg = destructive
        ? AppColors.danger
        : accent
        ? Colors.white
        : AppColors.primary;
    final labelColor = destructive ? AppColors.danger : AppColors.textPrimary;

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
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconFg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.body.copyWith(
                      color: labelColor,
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
            Icon(
              Icons.chevron_right_rounded,
              color: destructive
                  ? AppColors.danger.withValues(alpha: 0.5)
                  : AppColors.textTertiary,
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
