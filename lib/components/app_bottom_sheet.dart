import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final canvas = CanvasColors.of(context);
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: canvas.surface,
    isScrollControlled: isScrollControlled,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),
          Flexible(child: builder(ctx)),
        ],
      ),
    ),
  );
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.smd),
      decoration: BoxDecoration(
        color: AppColors.borderStrong,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
    );
  }
}
