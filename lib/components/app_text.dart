import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum AppTextStyleToken {
  display,
  h1,
  h2,
  h3,
  title,
  subtitle,
  body,
  small,
  caption,
  mono,
}

/// Typed text — never construct TextStyle inline in screens. Pulls sizes/weights
/// from the typography tokens (docs/components.md: "Always use AppText").
class AppText extends StatelessWidget {
  final String data;
  final AppTextStyleToken token;
  final Color? color;
  final FontWeight? weight;
  final int? maxLines;
  final TextAlign? align;

  const AppText(
    this.data, {
    super.key,
    this.token = AppTextStyleToken.body,
    this.color,
    this.weight,
    this.maxLines,
    this.align,
  });

  TextStyle get _base => switch (token) {
        AppTextStyleToken.display => AppType.display,
        AppTextStyleToken.h1 => AppType.h1,
        AppTextStyleToken.h2 => AppType.h2,
        AppTextStyleToken.h3 => AppType.h3,
        AppTextStyleToken.title => AppType.title,
        AppTextStyleToken.subtitle => AppType.subtitle,
        AppTextStyleToken.body => AppType.body,
        AppTextStyleToken.small => AppType.small,
        AppTextStyleToken.caption => AppType.caption,
        AppTextStyleToken.mono => monoStyle(),
      };

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      maxLines: maxLines,
      textAlign: align,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
      style: _base.copyWith(color: color, fontWeight: weight),
    );
  }
}
