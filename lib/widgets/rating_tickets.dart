import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RatingTickets extends StatelessWidget {
  final int rating;
  final int max;
  final double size;
  final Color color;
  final ValueChanged<int>? onChanged;

  const RatingTickets({
    super.key,
    required this.rating,
    this.max = 5,
    this.size = 22,
    this.color = AppColors.maroon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final interactive = onChanged != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(max, (i) {
        final filled = i < rating;
        final glyph = Icon(
          filled
              ? Amicons.iconly_ticket_fill
              : Amicons.iconly_ticket,
          size: size,
          color: filled ? color : AppColors.textTertiary.withValues(alpha: 0.6),
        );
        if (!interactive) {
          return Padding(
            padding: const EdgeInsets.only(right: 2),
            child: glyph,
          );
        }
        return Semantics(
          button: true,
          label: 'Rate ${i + 1} of $max',
          child: InkResponse(
            onTap: () {
              HapticFeedback.selectionClick();
              onChanged!(rating == i + 1 ? 0 : i + 1);
            },
            radius: size,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: glyph,
            ),
          ),
        );
      }),
    );
  }
}
