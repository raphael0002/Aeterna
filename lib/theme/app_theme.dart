import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens — Memory-Ticket-Stub-Design-System (design.md).
/// Crimson brand red hero + warm cream canvas + white ticket paper.
/// Warm-tinted shadows, tight print-like stub corners, mono stub numbers.
class AppColors {
  AppColors._();

  // ── Brand & interactive (terracotta orange, from reference) ──────────
  static const primary = Color(0xFFC1502C); // Brand Orange
  static const primaryDark = Color(0xFF9C3C1E); // pressed / hero gradient end
  static const primaryLight = Color(0xFFE07A4F); // highlight wash
  static const primaryFaint = Color(0xFFFBEADF); // faint orange wash / tint

  // ── Canvas & surfaces (warm-neutral, not clinical white) ─────────────
  static const canvas = Color(0xFFFAF7F2); // cream page — the "desk"
  static const canvasParchment = Color(0xFFF3EEE5); // deeper cream, stub footer
  static const surface = Color(0xFFFFFFFF); // ticket paper — pure white
  static const surfaceMuted = Color(0xFFF3EEE5); // input fill (cream)
  static const surfaceInset = Color(0xFFF3EEE5); // inset blocks = parchment

  // ── Text — warm ink ladder over cream (never pure #000) ──────────────
  static const textPrimary = Color(0xFF1C1B1A); // ink
  static const textSecondary = Color(0xFF5A5652); // ink-secondary
  static const textTertiary = Color(0xFF8F8A83); // ink-muted
  static const textDisabled = Color(0xFFBEB8AF); // ink-disabled
  static const textInverse = Color(0xFFFFFFFF);

  // ── Structural (warm borders + perforation) ──────────────────────────
  static const borderSubtle = Color(0xFFE5DFD5); // hairline
  static const borderDefault = Color(0xFFE5DFD5); // hairline
  static const borderStrong = Color(0xFFD4CCBE); // hairline-strong
  static const perforation = Color(0xFFB5AB98); // dashed tear-line

  // ── Semantic ─────────────────────────────────────────────────────────
  static const success = Color(0xFF4E8752);
  static const successBg = Color(0xFFE8F1E4);
  static const successText = Color(0xFF2F5732);
  static const warning = Color(0xFFE8A93C); // shares concert amber
  static const warningBg = Color(0xFFFDF4E4);
  static const info = Color(0xFF2E8B87); // shares travel teal
  static const infoBg = Color(0xFFE3F1F0);
  static const danger = Color(0xFFC62828); // distinct red for destructive

  // ── Semantic badges (repointed onto category washes) ─────────────────
  static const badgeInfoBg = infoBg;
  static const badgeInfoText = info;
  static const badgeSuccessBg = successBg;
  static const badgeSuccessText = successText;
  static const badgeWarnBg = warningBg;
  static const badgeWarnText = Color(0xFFB45309);

  // ── Category accents — the collection's color code (design.md) ───────
  static const catConcert = Color(0xFFE8A93C); // amber
  static const catConcertBg = Color(0xFFFDF4E4);
  static const catTravel = Color(0xFF2E8B87); // teal
  static const catTravelBg = Color(0xFFE3F1F0);
  static const catMilestone = Color(0xFFE56B5C); // coral
  static const catMilestoneBg = Color(0xFFFBE8E5);
  static const catEveryday = Color(0xFF7B9E6E); // sage
  static const catEverydayBg = Color(0xFFEDF2E9);

  // ── Utility ──────────────────────────────────────────────────────────
  static const black = Color(0xFF000000); // QR codes only (design.md)

  // ── Warm paper shadow tint ───────────────────────────────────────────
  static const paperShadow = Color(0x143C2814); // rgba(60,40,20,0.08)

  // ── Dark mode ("dim room") ───────────────────────────────────────────
  static const canvasDark = Color(0xFF1F1D1A);
  static const surfaceDark = Color(0xFFFFFFFF); // stubs stay white paper
  static const surfaceMutedDark = Color(0xFF2A2724);
  static const textPrimaryDark = Color(0xFFF5F1EA);
  static const textSecondaryDark = Color(0xFFA8A49C);
  static const borderDark = Color(0xFF302D28);
  static const borderSubtleDark = Color(0xFF252220);

  // ── Legacy aliases (repointed) ───────────────────────────────────────
  static const background = canvas;
  static const surfaceContainer = surfaceMuted;
  static const surfaceContainerHigh = surfaceInset;
  static const cream = canvas;
  static const ink = textPrimary;
  static const inkMuted = textSecondary;
  static const line = borderDefault;
  static const maroon = primary;
  static const forest = catTravel;
  static const mustard = warning;
  static const accent = warning;
  static const primaryPressed = primaryDark;
  static const primaryContainer = primaryFaint;
  static const backgroundDark = canvasDark;
  static const surfaceContainerDark = surfaceMutedDark;
  static const onCanvasDark = textPrimaryDark;
  static const onCanvasMutedDark = textSecondaryDark;
}

class AppSpacing {
  AppSpacing._();
  static const xs = 4.0;
  static const sm = 8.0;
  static const smd = 12.0;
  static const md = 16.0;
  static const lg = 20.0; // reference uses 20 as page padding
  static const xl = 24.0;
  static const xxl = 32.0;
  static const huge = 40.0;
  static const page = 20.0;
  static const sectionGap = 24.0;
  static const cardGap = 12.0;
  static const componentGap = 12.0;
}

/// Radius grammar (design.md): tight 4px stubs = print-like tickets,
/// generous 16px = app-chrome cards, 10px = buttons, pill = chips.
class AppRadii {
  AppRadii._();
  static const xs = 4.0; // ticket stub edges — tight, print-like
  static const sm = 6.0; // stub photo crops, inline imagery
  static const md = 10.0; // input fields, buttons
  static const lg = 16.0; // app-chrome cards (stats, settings)
  static const xl = 20.0; // sheet / content-sheet top corners
  static const xxl = 24.0; // modal sheets
  static const sheet = 20.0; // bottom sheet top corners
  static const ticket = 4.0; // the stub — print-like, NOT a UI card
  static const pill = 9999.0;
}

class AppMotion {
  AppMotion._();
  static const fast = Duration(milliseconds: 120);
  static const normal = Duration(milliseconds: 200);
  static const medium = Duration(milliseconds: 320);
  static const slow = Duration(milliseconds: 450);
  static const hero = Duration(milliseconds: 600);
  static const curve = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
}

/// Warm-tinted shadows — paper on a wooden desk, never cool black.
/// rgba(60,40,20,a). This is the single most important visual detail.
class AppElevation {
  AppElevation._();
  static const List<BoxShadow> none = [];
  // paper-rest — stubs at rest
  static List<BoxShadow> get level1 => const [
    BoxShadow(color: Color(0x143C2814), blurRadius: 8, offset: Offset(0, 2)),
  ];
  // paper-lift — stub tapped/hovered
  static List<BoxShadow> get level2 => const [
    BoxShadow(color: Color(0x1F3C2814), blurRadius: 16, offset: Offset(0, 4)),
  ];
  // paper-float — detail view / focused stub
  static List<BoxShadow> get level3 => const [
    BoxShadow(color: Color(0x293C2814), blurRadius: 32, offset: Offset(0, 8)),
  ];
  // brand-glow — primary CTA & FAB halo (orange)
  static List<BoxShadow> get redGlow => const [
    BoxShadow(color: Color(0x47C1502C), blurRadius: 20, offset: Offset(0, 6)),
  ];
  static List<BoxShadow> get floatingToolbar => const [
    BoxShadow(color: Color(0x143C2814), blurRadius: 12, offset: Offset(0, -2)),
  ];
}

/// Typography — reference uses bold geometric grotesk for numerals/hero,
/// Inter-class for body. Numerals get slight negative letter-spacing.
class AppType {
  AppType._();

  // Display / headings — Inter (design.md UI face). Slight negative tracking.
  static TextStyle _display(
    double size,
    FontWeight w, {
    double spacing = -0.5,
  }) => GoogleFonts.inter(
    fontSize: size,
    fontWeight: w,
    letterSpacing: spacing,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  // Body text
  static TextStyle _body(
    double size,
    double height,
    FontWeight w, {
    double spacing = 0,
  }) => GoogleFonts.inter(
    fontSize: size,
    height: height / size,
    fontWeight: w,
    letterSpacing: spacing,
    color: AppColors.textPrimary,
  );

  static TextStyle get hero => _display(36, FontWeight.w800);
  static TextStyle get display => _display(32, FontWeight.w800);
  static TextStyle get h1 => _display(28, FontWeight.w700, spacing: -0.4);
  static TextStyle get h2 => _display(22, FontWeight.w700, spacing: -0.3);
  static TextStyle get h3 => _display(18, FontWeight.w700, spacing: -0.2);

  static TextStyle get title => _body(17, 24, FontWeight.w600);
  static TextStyle get subtitle => _body(15, 22, FontWeight.w500);
  static TextStyle get body => _body(15, 22, FontWeight.w400);
  static TextStyle get small => _body(13, 18, FontWeight.w400);
  static TextStyle get caption => _body(11, 16, FontWeight.w500, spacing: 0.3);
  static TextStyle get button => _body(15, 20, FontWeight.w600);
}

/// Mono / stamp text — ticket numbers, meta.
TextStyle monoStyle({double size = 12, Color? color, FontWeight? weight}) =>
    GoogleFonts.jetBrainsMono(
      fontSize: size,
      color: color ?? AppColors.textPrimary,
      fontWeight: weight ?? FontWeight.w500,
      letterSpacing: 0.2,
    );

class CanvasColors extends ThemeExtension<CanvasColors> {
  final Color onCanvas;
  final Color onCanvasMuted;
  final Color surface;
  final Color surfaceMuted;
  final Color surfaceContainer;
  final Color border;
  final Color borderSubtle;
  final bool isDark;

  const CanvasColors({
    required this.onCanvas,
    required this.onCanvasMuted,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceContainer,
    required this.border,
    required this.borderSubtle,
    required this.isDark,
  });

  static CanvasColors of(BuildContext c) =>
      Theme.of(c).extension<CanvasColors>()!;

  @override
  CanvasColors copyWith({
    Color? onCanvas,
    Color? onCanvasMuted,
    Color? surface,
    Color? surfaceMuted,
    Color? surfaceContainer,
    Color? border,
    Color? borderSubtle,
    bool? isDark,
  }) => CanvasColors(
    onCanvas: onCanvas ?? this.onCanvas,
    onCanvasMuted: onCanvasMuted ?? this.onCanvasMuted,
    surface: surface ?? this.surface,
    surfaceMuted: surfaceMuted ?? this.surfaceMuted,
    surfaceContainer: surfaceContainer ?? this.surfaceContainer,
    border: border ?? this.border,
    borderSubtle: borderSubtle ?? this.borderSubtle,
    isDark: isDark ?? this.isDark,
  );

  @override
  CanvasColors lerp(ThemeExtension<CanvasColors>? other, double t) {
    if (other is! CanvasColors) return this;
    return CanvasColors(
      onCanvas: Color.lerp(onCanvas, other.onCanvas, t)!,
      onCanvasMuted: Color.lerp(onCanvasMuted, other.onCanvasMuted, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceMuted: Color.lerp(surfaceMuted, other.surfaceMuted, t)!,
      surfaceContainer: Color.lerp(
        surfaceContainer,
        other.surfaceContainer,
        t,
      )!,
      border: Color.lerp(border, other.border, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      isDark: t > 0.5 ? other.isDark : isDark,
    );
  }
}

ThemeData buildAppTheme({bool dark = false}) {
  final canvas = dark ? AppColors.canvasDark : AppColors.canvas;
  final onCanvas = dark ? AppColors.textPrimaryDark : AppColors.textPrimary;
  final onCanvasMuted = dark
      ? AppColors.textSecondaryDark
      : AppColors.textSecondary;
  final surfaceColor = dark ? AppColors.surfaceDark : AppColors.surface;
  final surfaceMutedColor = dark
      ? AppColors.surfaceMutedDark
      : AppColors.surfaceMuted;
  final borderColor = dark ? AppColors.borderDark : AppColors.borderDefault;
  final borderSubtleColor = dark
      ? AppColors.borderSubtleDark
      : AppColors.borderSubtle;

  return ThemeData(
    useMaterial3: true,
    brightness: dark ? Brightness.dark : Brightness.light,
    // Inter is the UI face — any TextStyle without an explicit family inherits it.
    fontFamily: GoogleFonts.inter().fontFamily,
    scaffoldBackgroundColor: canvas,
    colorScheme: ColorScheme(
      brightness: dark ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: AppColors.primaryFaint,
      onPrimaryContainer: AppColors.primaryDark,
      secondary: AppColors.badgeInfoText,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.badgeInfoBg,
      onSecondaryContainer: AppColors.badgeInfoText,
      tertiary: AppColors.badgeSuccessText,
      onTertiary: Colors.white,
      tertiaryContainer: AppColors.badgeSuccessBg,
      onTertiaryContainer: AppColors.badgeSuccessText,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surfaceColor,
      onSurface: onCanvas,
      onSurfaceVariant: onCanvasMuted,
      outline: borderColor,
      outlineVariant: borderSubtleColor,
      shadow: Colors.black,
      inverseSurface: dark ? AppColors.surface : AppColors.canvasDark,
      onInverseSurface: dark ? AppColors.textPrimary : Colors.white,
      inversePrimary: AppColors.primaryLight,
      surfaceTint: Colors.transparent,
    ),
    extensions: [
      CanvasColors(
        onCanvas: onCanvas,
        onCanvasMuted: onCanvasMuted,
        surface: surfaceColor,
        surfaceMuted: surfaceMutedColor,
        surfaceContainer: surfaceMutedColor,
        border: borderColor,
        borderSubtle: borderSubtleColor,
        isDark: dark,
      ),
    ],
    appBarTheme: AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: onCanvas,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      systemOverlayStyle: dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      titleTextStyle: AppType.h3.copyWith(color: onCanvas),
    ),
    dividerTheme: DividerThemeData(
      color: borderSubtleColor,
      thickness: 1,
      space: 1,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
        disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: AppType.button,
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onCanvas,
        side: BorderSide(color: borderColor, width: 1.5),
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        textStyle: AppType.button,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: AppType.button,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceMutedColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      hintStyle: AppType.body.copyWith(color: onCanvasMuted),
      labelStyle: AppType.small.copyWith(color: onCanvasMuted),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : onCanvasMuted,
        ),
        side: WidgetStateProperty.all(BorderSide.none),
        textStyle: WidgetStateProperty.all(
          AppType.small.copyWith(fontWeight: FontWeight.w600),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.textPrimary,
      contentTextStyle: AppType.body.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: 4,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.xl),
      ),
      titleTextStyle: AppType.h3.copyWith(color: onCanvas),
      contentTextStyle: AppType.body.copyWith(color: onCanvasMuted),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadii.sheet),
        ),
      ),
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      extendedTextStyle: AppType.button,
    ),
    listTileTheme: ListTileThemeData(
      tileColor: Colors.transparent,
      titleTextStyle: AppType.body.copyWith(color: onCanvas),
      subtitleTextStyle: AppType.small.copyWith(color: onCanvasMuted),
    ),
    iconTheme: IconThemeData(color: onCanvas, size: 22),
    textTheme: TextTheme(
      displayLarge: AppType.hero,
      displayMedium: AppType.display,
      displaySmall: AppType.h1,
      headlineLarge: AppType.h1,
      headlineMedium: AppType.h2,
      headlineSmall: AppType.h3,
      titleLarge: AppType.title,
      titleMedium: AppType.subtitle,
      titleSmall: AppType.body.copyWith(fontWeight: FontWeight.w600),
      bodyLarge: AppType.body,
      bodyMedium: AppType.small,
      bodySmall: AppType.caption,
      labelLarge: AppType.button,
      labelMedium: AppType.caption,
      labelSmall: AppType.caption.copyWith(fontSize: 10),
    ).apply(bodyColor: onCanvas, displayColor: onCanvas),
  );
}
