import 'package:amicons/amicons.dart';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../components/app_chip.dart';
import '../components/app_empty_state.dart';
import '../components/hero_sheet_scaffold.dart';
import '../models/ticket.dart';
import '../providers/ticket_store_provider.dart';
import '../providers/filter_providers.dart';
import '../theme/app_theme.dart';

class ScrapbookScreen extends ConsumerStatefulWidget {
  const ScrapbookScreen({super.key});

  @override
  ConsumerState<ScrapbookScreen> createState() => _ScrapbookScreenState();
}

class _ScrapbookScreenState extends ConsumerState<ScrapbookScreen> {
  void _open(BuildContext context, Ticket t) => context.push('/ticket/${t.id}');
  void _add(BuildContext context) => context.push('/new');

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(ticketStoreProvider);
    final all = store.tickets;
    final filter = ref.watch(categoryFilterProvider);

    if (all.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Gallery', style: AppType.h1)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _add(context),
          icon: const Icon(Amicons.iconly_plus_fill),
          label: const Text('New stub'),
        ),
        body: AppEmptyState(
          icon: Amicons.iconly_category_fill,
          title: 'Your gallery is empty',
          message: 'Saved memories appear here as a collage.',
          ctaLabel: 'New stub',
          onCta: () => _add(context),
        ),
      );
    }

    final tickets = filter == null
        ? all
        : all.where((t) => t.category == filter).toList();

    return HeroSheetScaffold(
      heroColor: AppColors.primary,
      heroFraction: 0.26,
      hero: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Gallery',
            style: AppType.small.copyWith(
              color: Colors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your collage',
            style: AppType.hero.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '${all.length} memories captured',
            style: AppType.body.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
      sheet: Column(
        children: [
          // Category chips
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.page,
                vertical: 12,
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: AppChip(
                    label: 'All',
                    selected: filter == null,
                    onTap: () =>
                        ref.read(categoryFilterProvider.notifier).state = null,
                  ),
                ),
                for (final c in TicketCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: AppChip(
                      label: c.label,
                      icon: c.icon,
                      selected: filter == c,
                      color: c.color,
                      onTap: () =>
                          ref.read(categoryFilterProvider.notifier).state =
                              filter == c ? null : c,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: tickets.isEmpty
                ? Center(
                    child: Text(
                      'No ${filter?.label ?? ''} memories yet',
                      style: AppType.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : MasonryGridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.page,
                      4,
                      AppSpacing.page,
                      100,
                    ),
                    itemCount: tickets.length,
                    itemBuilder: (ctx, i) => _ScrapCard(
                      ticket: tickets[i],
                      onTap: () => _open(ctx, tickets[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _ScrapCard extends StatelessWidget {
  final Ticket ticket;
  final VoidCallback onTap;
  const _ScrapCard({required this.ticket, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppElevation.level1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Media(ticket: ticket),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: ticket.category.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ticket.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.body.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      if (ticket.favorite)
                        const Icon(
                          Amicons.iconly_heart_fill,
                          size: 12,
                          color: AppColors.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(ticket.date),
                    style: monoStyle(size: 10, color: AppColors.textSecondary),
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

class _Media extends StatelessWidget {
  final Ticket ticket;
  const _Media({required this.ticket});

  @override
  Widget build(BuildContext context) {
    final path = ticket.imagePath;
    if (path != null && File(path).existsSync()) {
      return Image.file(
        File(path),
        fit: BoxFit.fitWidth,
        width: double.infinity,
      );
    }
    final h = 100.0 + (ticket.id.hashCode.abs() % 80);
    return Container(
      height: h,
      color: ticket.category.color.withValues(alpha: 0.10),
      child: Center(
        child: Icon(
          ticket.category.icon,
          size: 36,
          color: ticket.category.color.withValues(alpha: 0.55),
        ),
      ),
    );
  }
}
