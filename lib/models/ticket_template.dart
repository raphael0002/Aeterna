import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Visual templates for the ticket stub. Each is a *config* applied to the
/// shared stub skeleton (same anatomy — header, blocks, perforation) so the
/// design system stays consistent and new templates can later be served from
/// the backend without an app release.
enum TicketTemplate { classic, minimal, accent, mono }

extension TicketTemplateX on TicketTemplate {
  String get label => switch (this) {
        TicketTemplate.classic => 'Classic',
        TicketTemplate.minimal => 'Minimal',
        TicketTemplate.accent => 'Accent',
        TicketTemplate.mono => 'Mono',
      };

  String get blurb => switch (this) {
        TicketTemplate.classic => 'Warm paper, category color',
        TicketTemplate.minimal => 'Monochrome ink, airy',
        TicketTemplate.accent => 'Bold category header band',
        TicketTemplate.mono => 'Industrial mono type',
      };

  /// Accent color for this template given the ticket's category color.
  /// Minimal drops the category hue for a monochrome ink look.
  Color accent(Color categoryColor) =>
      this == TicketTemplate.minimal ? AppColors.textPrimary : categoryColor;

  /// Fill behind the info blocks.
  Color get blockBg =>
      this == TicketTemplate.minimal ? AppColors.surfaceMuted : const Color(0xFFF3EEE5);

  /// Show a colored header band behind the title.
  bool get headerBand => this == TicketTemplate.accent;

  /// Use monospace type for labels/values (ticket-stub industrial feel).
  bool get mono => this == TicketTemplate.mono;

  /// Resolve to concrete style values for a given category color.
  TemplateStyle resolve(Color categoryColor) => TemplateStyle(
        accent: accent(categoryColor),
        blockBg: blockBg,
        mono: mono,
        headerBand: headerBand,
      );
}

/// Concrete, resolved style the stub widgets render against.
class TemplateStyle {
  final Color accent;
  final Color blockBg;
  final bool mono;
  final bool headerBand;
  const TemplateStyle({
    required this.accent,
    required this.blockBg,
    required this.mono,
    required this.headerBand,
  });
}

TicketTemplate templateFromName(String? name) => TicketTemplate.values.firstWhere(
      (t) => t.name == name,
      orElse: () => TicketTemplate.classic,
    );
