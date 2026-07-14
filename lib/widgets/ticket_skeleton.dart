import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Subtle looping opacity pulse — a dependency-free shimmer.
class Pulse extends StatefulWidget {
  final Widget child;
  const Pulse({super.key, required this.child});

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(
        CurvedAnimation(parent: _c, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

Color get _bone => AppColors.borderSubtle;

Widget _bar(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: _bone,
        borderRadius: BorderRadius.circular(6),
      ),
    );

/// Skeleton matching the compact (horizontal) ticket used in lists.
class CompactTicketSkeleton extends StatelessWidget {
  const CompactTicketSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Pulse(
      child: Container(
        height: 108,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Color(0x143C2814), blurRadius: 14, offset: Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                color: _bone,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _bar(70, 10),
                  const SizedBox(height: 10),
                  _bar(150, 14),
                  const SizedBox(height: 10),
                  _bar(110, 10),
                ],
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

/// A list of compact skeletons for a loading list.
class TicketListSkeleton extends StatelessWidget {
  final int count;
  final EdgeInsetsGeometry padding;
  const TicketListSkeleton({
    super.key,
    this.count = 5,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 120),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, _) => const CompactTicketSkeleton(),
    );
  }
}
