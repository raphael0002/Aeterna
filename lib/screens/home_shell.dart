import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/floating_nav_bar.dart';
import '../models/ticket.dart';
import '../providers/filter_providers.dart';
import '../theme/app_theme.dart';
import 'calendar_screen.dart';
import 'gallery_screen.dart';
import 'map_screen.dart';
import 'wallet_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  static const _items = [
    AppNavItem(
      icon: Icons.confirmation_number_outlined,
      selectedIcon: Icons.confirmation_number,
      label: 'Wallet',
    ),
    AppNavItem(
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view_rounded,
      label: 'Gallery',
    ),
    AppNavItem(
      icon: Icons.calendar_month_outlined,
      selectedIcon: Icons.calendar_month_rounded,
      label: 'Calendar',
    ),
    AppNavItem(
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
      label: 'Map',
    ),
  ];

  bool get _isFilterPage => _index == 0 || _index == 1;
  bool get _isMapPage => _index == 3;

  IconData get _fabIcon => _isFilterPage
      ? Icons.tune_rounded
      : _isMapPage
      ? Icons.add_location_alt_rounded
      : Icons.add_rounded;

  String get _fabTooltip => _isFilterPage
      ? 'Filter'
      : _isMapPage
      ? 'New with location'
      : 'New stub';

  void _onFab() {
    if (_isFilterPage) {
      _openFilterSheet();
    } else {
      HapticFeedback.mediumImpact();
      context.push('/new');
    }
  }

  void _openFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => _FilterSheet(currentTab: _index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFFFAF7F2),
      body: IndexedStack(
        index: _index,
        children: const [
          WalletScreen(),
          GalleryScreen(),
          CalendarScreen(),
          MapScreen(),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        items: _items,
        index: _index,
        onSelect: (i) {
          if (i == _index) return;
          HapticFeedback.selectionClick();
          setState(() => _index = i);
        },
        fabIcon: _fabIcon,
        fabTooltip: _fabTooltip,
        onFab: _onFab,
      ),
    );
  }
}

// ═══ FILTER SHEET ═════════════════════════════════════════════════
class _FilterSheet extends ConsumerWidget {
  final int currentTab;

  const _FilterSheet({required this.currentTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryFilterProvider);
    final starred = ref.watch(starredOnlyProvider);
    final isWalletTab = currentTab == 0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Grabber ─────────────────────────────────
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(top: 10, bottom: 6),
                  decoration: BoxDecoration(
                    color: AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              // ── Header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primaryFaint,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Filter',
                            style: AppType.h3.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Narrow down your memories',
                            style: AppType.small.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: AppColors.borderSubtle,
              ),

              // ── Category section ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Text(
                      'CATEGORY',
                      style: monoStyle(
                        size: 11,
                        color: AppColors.textSecondary,
                        weight: FontWeight.w700,
                      ).copyWith(letterSpacing: 1.4),
                    ),
                    const Spacer(),
                    if (selected != null)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(categoryFilterProvider.notifier).state =
                              null;
                        },
                        child: Text(
                          'Clear',
                          style: AppType.small.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterChip(
                      label: 'All',
                      icon: Icons.apps_rounded,
                      color: AppColors.primary,
                      selected: selected == null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(categoryFilterProvider.notifier).state = null;
                      },
                    ),
                    for (final c in TicketCategory.values)
                      _FilterChip(
                        label: c.label,
                        icon: c.icon,
                        color: c.color,
                        selected: selected == c,
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(categoryFilterProvider.notifier).state =
                              selected == c ? null : c;
                        },
                      ),
                  ],
                ),
              ),

              // ── Starred toggle (wallet only) ────────────
              if (isWalletTab) ...[
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: AppColors.borderSubtle,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'SHOW ONLY',
                    style: monoStyle(
                      size: 11,
                      color: AppColors.textSecondary,
                      weight: FontWeight.w700,
                    ).copyWith(letterSpacing: 1.4),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Material(
                    color: starred
                        ? AppColors.primaryFaint
                        : const Color(0xFFF5F1EA),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(starredOnlyProvider.notifier).state = !starred;
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: starred
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: starred
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: const Color(0x143C2814),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                              ),
                              child: Icon(
                                starred
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 20,
                                color: starred
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Starred only',
                                    style: AppType.body.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    starred
                                        ? 'Showing favorites only'
                                        : 'Show all memories',
                                    style: AppType.small.copyWith(
                                      color: AppColors.textTertiary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: starred,
                              activeColor: AppColors.primary,
                              onChanged: (v) {
                                HapticFeedback.selectionClick();
                                ref.read(starredOnlyProvider.notifier).state =
                                    v;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],

              // ── Actions ─────────────────────────────────
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ref.read(categoryFilterProvider.notifier).state =
                              null;
                          ref.read(starredOnlyProvider.notifier).state = false;
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          side: const BorderSide(
                            color: AppColors.borderDefault,
                            width: 1.2,
                          ),
                          foregroundColor: AppColors.textPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: AppType.button.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: () => Navigator.pop(context),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          'Show results',
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
      ),
    );
  }
}

// ─── Filter chip ─────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : const Color(0xFFF5F1EA),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? color : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppType.small.copyWith(
                color: selected ? color : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
