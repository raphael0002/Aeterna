---
version: 1.0
name: Memory-Ticket-Stub-Design-System
description: >
  A collectible-ticket interface that turns life moments into tactile digital
  keepsakes. Every photo becomes a ticket stub — a small physical object with a
  perforated edge, a stub number, a category stamp, and a barcode. The system
  is built on a warm cream canvas (not clinical white) that lets photos and
  ticket paper breathe as if resting on a wooden desk. A crimson Brand Red
  (#C62828) carries interactive intent; four category accents (amber, teal,
  coral, sage) let users scan a collection at a glance without breaking the
  monochrome UI chrome. Typography pairs a clean grotesque (Inter) for UI with
  a monospace face (JetBrains Mono) for stub numbers and dates — the mono is
  the typographic fingerprint that says "this is a real ticket, printed by a
  machine." Elevation is soft and warm-tinted so stubs feel like paper on a
  surface, not glass panes floating in space. Motion is purposeful: a stamp
  comes down, a perforation tears, a ticket flips. Every screen is a ticket
  window; every card is a keepsake.

  This system is Flutter-native, offline-first, and designed to work with
  Riverpod for state, Drift for local persistence, and Rive for the signature
  "stamping" moment. All tokens map directly to Flutter primitives (Color,
  TextStyle, BorderRadius, BoxShadow, Duration, Curve) and are exposed via a
  ThemeExtension for consistent access across the widget tree.

colors:
  # Brand & interactive
  primary: "#C62828" # Brand Red — CTAs, focused states, brand marks
  primary-dark: "#8E0000" # Pressed CTA, hero gradient end
  primary-light: "#FF5F52" # Highlight wash on white surfaces
  primary-glow-30: "rgba(198, 40, 40, 0.30)" # CTA drop shadow
  primary-glow-10: "rgba(198, 40, 40, 0.10)" # Focus ring
  on-primary: "#FFFFFF"
  on-primary-70: "rgba(255, 255, 255, 0.70)"
  on-primary-15: "rgba(255, 255, 255, 0.15)"

  # Category accents (the color code for the collection)
  category-concert: "#E8A93C" # Amber — concerts, gigs, shows
  category-concert-bg: "#FDF4E4" # Amber wash for tag bg / stub header tint
  category-travel: "#2E8B87" # Teal — trips, flights, road trips
  category-travel-bg: "#E3F1F0" # Teal wash
  category-milestone: "#E56B5C" # Coral — birthdays, weddings, first-times
  category-milestone-bg: "#FBE8E5" # Coral wash
  category-everyday: "#7B9E6E" # Sage — small moments, ordinary joys
  category-everyday-bg: "#EDF2E9" # Sage wash

  # Canvas & surface (warm-neutral, not clinical white)
  canvas: "#FAF7F2" # Cream page background — the "desk surface"
  canvas-parchment: "#F3EEE5" # Slightly deeper cream for grouping bands
  surface-paper: "#FFFFFF" # Ticket stub paper — pure white for photo contrast
  surface-input: "#F3EEE5" # Text input fill (cream, not gray)
  surface-elevated: "#FFFFFF" # Sheet & modal surfaces
  surface-scrim: "rgba(28, 27, 26, 0.60)" # Modal/backdrop dim

  # Hero surface
  surface-hero-start: "#C62828" # Gradient begin
  surface-hero-end: "#8E0000" # Gradient end

  # Text — ink over cream (warm near-black, not #000)
  ink: "#1C1B1A" # Warm near-black — primary text on cream
  ink-secondary: "#5A5652" # Body text, secondary info
  ink-muted: "#8F8A83" # Captions, dates, placeholder
  ink-disabled: "#BEB8AF" # Disabled text
  ink-on-hero: "#FFFFFF" # Text on hero gradient
  ink-on-hero-70: "rgba(255, 255, 255, 0.70)"

  # Structural
  hairline: "#E5DFD5" # Warm 1px border (not cool gray)
  hairline-strong: "#D4CCBE" # Stronger divider for card edges
  perforation: "#B5AB98" # The dashed tear-line color (warm mid-gray)
  divider-soft: "rgba(28, 27, 26, 0.04)"

  # Semantic
  success: "#4E8752"
  success-bg: "#E8F1E4"
  success-text: "#2F5732"
  error: "#C62828" # Shares primary red
  error-bg: "#FBE8E5"
  warning: "#E8A93C" # Shares category-concert amber
  warning-bg: "#FDF4E4"
  info: "#2E8B87" # Shares category-travel teal
  info-bg: "#E3F1F0"

  # Utility
  black: "#000000" # Reserved for QR codes and true void only
  paper-shadow-tint: "rgba(60, 40, 20, 0.08)" # Warm-tinted paper shadow

typography:
  # Display / hero
  hero-code:
    fontFamily: "Inter, SF Pro Display, system-ui, sans-serif"
    fontSize: 48
    fontWeight: 700
    height: 1.0
    letterSpacing: 2.0
  ticket-number:
    fontFamily: "JetBrains Mono, SF Mono, Fira Code, monospace"
    fontSize: 22
    fontWeight: 600
    height: 1.2
    letterSpacing: 1.5
  ticket-prefix:
    fontFamily: "Georgia, Times New Roman, serif"
    fontSize: 22
    fontWeight: 700
    height: 1.2
    letterSpacing: 0.5
    fontStyle: italic
  stub-number:
    fontFamily: "JetBrains Mono, SF Mono, Fira Code, monospace"
    fontSize: 13
    fontWeight: 500
    height: 1.2
    letterSpacing: 1.2
  admit-one:
    fontFamily: "JetBrains Mono, SF Mono, Fira Code, monospace"
    fontSize: 10
    fontWeight: 600
    height: 1.0
    letterSpacing: 2.0
    textTransform: uppercase

  # Headings
  h1:
    fontFamily: "Inter, SF Pro Display, system-ui, sans-serif"
    fontSize: 28
    fontWeight: 700
    height: 1.25
    letterSpacing: -0.4
  h2:
    fontFamily: "Inter, SF Pro Display, system-ui, sans-serif"
    fontSize: 22
    fontWeight: 700
    height: 1.3
    letterSpacing: -0.3
  h3:
    fontFamily: "Inter, SF Pro Display, system-ui, sans-serif"
    fontSize: 18
    fontWeight: 600
    height: 1.4
    letterSpacing: -0.2

  # Ticket-specific
  ticket-title:
    fontFamily: "Inter, SF Pro Display, system-ui, sans-serif"
    fontSize: 20
    fontWeight: 700
    height: 1.25
    letterSpacing: -0.3
  ticket-note:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 14
    fontWeight: 400
    height: 1.5
    letterSpacing: 0
    fontStyle: italic

  # Body
  body:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 15
    fontWeight: 400
    height: 1.5
    letterSpacing: 0
  body-medium:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 15
    fontWeight: 500
    height: 1.5
    letterSpacing: 0
  caption:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 13
    fontWeight: 400
    height: 1.4
    letterSpacing: 0.1

  # UI labels
  label:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 11
    fontWeight: 600
    height: 1.3
    letterSpacing: 1.2
    textTransform: uppercase
  tag:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 12
    fontWeight: 600
    height: 1.0
    letterSpacing: 0.3
  micro:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 11
    fontWeight: 400
    height: 1.3
    letterSpacing: 0.2
  nav-title:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 15
    fontWeight: 600
    height: 1.3
    letterSpacing: 0
  cta-button:
    fontFamily: "Inter, SF Pro Text, system-ui, sans-serif"
    fontSize: 16
    fontWeight: 600
    height: 1.0
    letterSpacing: 0.1

  # Metadata (date, place, weather on stubs)
  stub-meta:
    fontFamily: "JetBrains Mono, SF Mono, Fira Code, monospace"
    fontSize: 11
    fontWeight: 500
    height: 1.3
    letterSpacing: 0.5
    textTransform: uppercase

rounded:
  none: 0
  xs: 4 # Ticket edges — print-like, tight
  sm: 6 # Stub photo crops, inline card imagery
  md: 10 # Input fields, secondary buttons
  lg: 16 # App chrome cards (settings, sheets)
  xl: 20 # Bottom sheet top corners
  xxl: 24 # Modal sheets
  pill: 9999
  full: 9999

spacing:
  hairline: 2
  xxs: 4
  xs: 8
  sm: 12
  md: 16
  lg: 20
  xl: 24
  xxl: 32
  xxxl: 40
  section: 48
  screen-px: 16
  card-px: 20
  card-py: 20
  stub-header-py: 12
  stub-body-py: 16
  stub-footer-py: 14

elevation:
  none:
    offset: [0, 0]
    blur: 0
    color: "transparent"

  # Warm-tinted shadows — paper resting on wood, not glass in space
  paper-rest: # A stub resting on the cream canvas
    offset: [0, 2]
    blur: 8
    spread: 0
    color: "rgba(60, 40, 20, 0.08)"
  paper-lift: # A stub being tapped / hovered
    offset: [0, 4]
    blur: 16
    spread: 0
    color: "rgba(60, 40, 20, 0.12)"
  paper-float: # Detail view / focused stub
    offset: [0, 8]
    blur: 32
    spread: 0
    color: "rgba(60, 40, 20, 0.16)"
  sheet: # Bottom sheet elevation
    offset: [0, -4]
    blur: 24
    spread: 0
    color: "rgba(60, 40, 20, 0.10)"
  red-glow: # Primary CTA button glow
    offset: [0, 6]
    blur: 20
    spread: 0
    color: "rgba(198, 40, 40, 0.28)"
  bottom-bar-up:
    offset: [0, -2]
    blur: 12
    spread: 0
    color: "rgba(60, 40, 20, 0.08)"

gradients:
  hero:
    type: linear
    begin: topLeft
    end: bottomRight
    colors: ["#C62828", "#8E0000"]
  hero-overlay: # Optional map/paper texture blend layer
    type: linear
    begin: topCenter
    end: bottomCenter
    colors: ["rgba(198, 40, 40, 0.00)", "rgba(142, 0, 0, 0.20)"]

durations:
  # Standard motion durations from the app blueprint
  micro: 100 # Button press, tap feedback
  fast: 150 # Card press, chip toggle
  base: 250 # Screen transitions, sheet rise
  slow: 350 # Ticket flip halfway
  stamp: 600 # Signature: stub gets stamped (the emotional payoff)
  celebrate: 900 # Confetti / milestone

curves:
  standard: "Curves.easeInOut"
  emphasized: "Curves.easeOutCubic"
  spring: "Cubic(0.175, 0.885, 0.32, 1.275)"
  stamp: "Cubic(0.4, 0.0, 0.2, 1.0)" # Weighty, decisive, like an ink stamp
  sheet-rise: "Cubic(0.16, 1.0, 0.3, 1.0)"
  flip: "Curves.easeInOutCubic"

components:
  # ─── NAVIGATION ─────────────────────────────────────────

  nav-bar:
    height: 48
    padding: "0 {spacing.md}"
    layout: "Row, mainAxisAlignment: spaceBetween, crossAxisAlignment: center"
    children:
      back-button:
        size: 40
        rounded: "{rounded.full}"
        icon: "chevron-left, 22px"
      title:
        typography: "{typography.nav-title}"
        alignment: center
      action-button:
        size: 40
        rounded: "{rounded.full}"

  nav-bar-on-cream:
    extends: "nav-bar"
    background: transparent
    back-button-bg: "{colors.surface-paper}"
    back-button-icon-color: "{colors.ink}"
    title-color: "{colors.ink}"
    action-button-bg: "{colors.surface-paper}"
    action-button-icon-color: "{colors.ink-secondary}"

  nav-bar-on-hero:
    extends: "nav-bar"
    background: transparent
    back-button-bg: "{colors.on-primary-15}"
    back-button-icon-color: "{colors.on-primary}"
    title-color: "{colors.on-primary}"
    action-button-bg: "{colors.on-primary-15}"
    action-button-icon-color: "{colors.on-primary}"

  # ─── HERO ────────────────────────────────────────────────

  hero-collection:
    background: "{gradients.hero}"
    padding: "60 top (incl. status bar), {spacing.xl} horizontal, {spacing.xl} bottom"
    children:
      nav-row: "{components.nav-bar-on-hero}"
      title:
        typography: "{typography.h1}"
        color: "{colors.on-primary}"
        marginTop: "{spacing.lg}"
      subtitle:
        typography: "{typography.body}"
        color: "{colors.on-primary-70}"
        marginTop: "{spacing.xxs}"
      stat-row:
        marginTop: "{spacing.xl}"
        layout: "Row, gap: {spacing.xl}"
        stat:
          value:
            typography: "{typography.hero-code}"
            fontSize: 32
            color: "{colors.on-primary}"
          label:
            typography: "{typography.label}"
            color: "{colors.on-primary-70}"

  # ─── CONTENT SHEET ──────────────────────────────────────

  content-sheet:
    background: "{colors.canvas}"
    borderRadius: "{rounded.xl} {rounded.xl} 0 0"
    marginTop: -20 # Overlaps hero
    minHeight: "screen height minus hero"
    padding: "{spacing.xl} {spacing.screen-px} 0"
    elevation: "{elevation.sheet}"

  # ─── TICKET STUB (THE CORE COLLECTIBLE) ────────────────

  ticket-stub:
    background: "{colors.surface-paper}"
    borderRadius: "{rounded.xs}"
    elevation: "{elevation.paper-rest}"
    layout: "Column"
    overflow: hidden
    # A stub is composed of three parts separated by a perforation
    children:
      # ── Header strip ───────────────────────────────────
      header:
        padding: "{spacing.sm} {spacing.md}"
        background: "{colors.category-*-bg}" # Tinted by category
        borderBottom: "1px solid {colors.hairline}"
        layout: "Row, crossAxisAlignment: center, gap: {spacing.xs}"
        children:
          category-icon:
            size: 16
            color: "{colors.category-*}" # Full-strength category color
          category-name:
            typography: "{typography.label}"
            color: "{colors.category-*}"
            flex: 1
          stub-number:
            typography: "{typography.stub-number}"
            color: "{colors.ink-secondary}"

      # ── Hero photo ─────────────────────────────────────
      photo:
        aspectRatio: "4:5" # Locked ratio for grid uniformity
        fit: cover
        background: "{colors.canvas-parchment}" # Fallback while loading

      # ── Body: title + meta ─────────────────────────────
      body:
        padding: "{spacing.md} {spacing.md} {spacing.sm}"
        layout: "Column, gap: {spacing.xxs}"
        children:
          title:
            typography: "{typography.ticket-title}"
            color: "{colors.ink}"
            maxLines: 2
            ellipsis: true
          meta-row:
            layout: "Row, gap: {spacing.sm}, crossAxisAlignment: center"
            marginTop: "{spacing.xxs}"
            date:
              typography: "{typography.stub-meta}"
              color: "{colors.ink-muted}"
            separator: "· (dot, {colors.ink-muted})"
            place:
              typography: "{typography.stub-meta}"
              color: "{colors.ink-muted}"
              ellipsis: true

      # ── Perforation (the signature tear line) ──────────
      perforation: "{components.perforation-line}"

      # ── Footer stub ────────────────────────────────────
      footer:
        padding: "{spacing.sm} {spacing.md}"
        layout: "Row, crossAxisAlignment: center, mainAxisAlignment: spaceBetween"
        background: "{colors.canvas-parchment}" # Slightly darker cream = stub tint
        children:
          admit-one:
            typography: "{typography.admit-one}"
            color: "{colors.ink-secondary}"
            content: "ADMIT ONE"
          barcode:
            width: 60
            height: 20
            component: "{components.barcode}"

  ticket-stub-pressed:
    extends: "ticket-stub"
    transform: "scale(0.98)"
    elevation: "{elevation.paper-rest}" # Shadow tightens on press
    transition: "{durations.fast}ms {curves.standard}"

  ticket-stub-featured: # Large detail-view variant
    extends: "ticket-stub"
    elevation: "{elevation.paper-float}"
    borderRadius: "{rounded.sm}"

  # ─── PERFORATION LINE ──────────────────────────────────

  perforation-line:
    height: 20
    position: relative
    margin: "0" # Full width of stub
    children:
      notch-left:
        size: 20
        borderRadius: "{rounded.full}"
        background: "{colors.canvas}" # Matches page bg for punched effect
        position: "absolute, left: -10, top: 50%, transformY: -50%"
      dashed-line:
        position: "absolute, inset: 0"
        content: "CustomPainter with 1.5px dashed stroke, gap: 4px, color: {colors.perforation}"
      notch-right:
        size: 20
        borderRadius: "{rounded.full}"
        background: "{colors.canvas}"
        position: "absolute, right: -10, top: 50%, transformY: -50%"

  # ─── BARCODE (decorative stub element) ────────────────

  barcode:
    background: transparent
    content: "CustomPainter — vertical bars of varying width in {colors.ink}, height fills container"
    ariaLabel: "Ticket barcode decoration"

  # ─── QR CODE BLOCK ─────────────────────────────────────

  qr-block:
    background: "{colors.surface-paper}"
    border: "1px solid {colors.hairline}"
    borderRadius: "{rounded.sm}"
    padding: "{spacing.xl}"
    layout: "Column, crossAxisAlignment: center"
    children:
      qr:
        size: 180
        color: "{colors.black}" # QR must be pure black for scanability
        background: "{colors.surface-paper}"
        errorCorrection: "M"
        marginBottom: "{spacing.md}"
      caption:
        typography: "{typography.caption}"
        color: "{colors.ink-muted}"
        alignment: center

  # ─── GRID COLLECTION VIEW ──────────────────────────────

  stub-grid:
    layout: "GridView.count, crossAxisCount: 2, mainAxisSpacing: {spacing.md}, crossAxisSpacing: {spacing.md}"
    padding: "{spacing.md} {spacing.screen-px}"
    childAspectRatio: 0.68 # Portrait — matches stub proportions
    physics: "BouncingScrollPhysics"

  stub-grid-item:
    child: "{components.ticket-stub}"
    onTap: "hero-transition to detail view"

  # ─── CATEGORY CHIPS / FILTER PILLS ─────────────────────

  category-chip:
    height: 34
    padding: "0 {spacing.md}"
    borderRadius: "{rounded.pill}"
    background: "{colors.surface-paper}"
    border: "1px solid {colors.hairline}"
    layout: "Row, gap: {spacing.xs}, crossAxisAlignment: center"
    icon:
      size: 14
      color: "{colors.category-*}"
    label:
      typography: "{typography.tag}"
      color: "{colors.ink}"

  category-chip-selected:
    extends: "category-chip"
    background: "{colors.category-*-bg}"
    border: "1.5px solid {colors.category-*}"
    label-color: "{colors.category-*}"

  category-chip-row:
    layout: "SingleChildScrollView, horizontal, gap: {spacing.xs}"
    padding: "{spacing.xs} {spacing.screen-px}"

  # ─── TAGS ──────────────────────────────────────────────

  tag:
    borderRadius: "{rounded.pill}"
    padding: "{spacing.xxs} {spacing.sm}"
    typography: "{typography.tag}"

  tag-category: # Colored per category
    extends: "tag"
    background: "{colors.category-*-bg}"
    color: "{colors.category-*}"

  tag-success:
    extends: "tag"
    background: "{colors.success-bg}"
    color: "{colors.success-text}"

  tag-neutral:
    extends: "tag"
    background: "{colors.canvas-parchment}"
    color: "{colors.ink-secondary}"

  # ─── BUTTONS ───────────────────────────────────────────

  button-primary:
    width: "full"
    height: 52
    background: "{colors.primary}"
    color: "{colors.on-primary}"
    typography: "{typography.cta-button}"
    borderRadius: "{rounded.md}"
    elevation: "{elevation.red-glow}"
    layout: "Row, mainAxisAlignment: center, gap: {spacing.xs}"

  button-primary-pressed:
    extends: "button-primary"
    background: "{colors.primary-dark}"
    transform: "scale(0.97)"
    elevation:
      offset: [0, 3]
      blur: 10
      color: "rgba(198, 40, 40, 0.20)"
    transition: "{durations.micro}ms {curves.standard}"

  button-primary-disabled:
    extends: "button-primary"
    background: "{colors.hairline-strong}"
    color: "{colors.ink-disabled}"
    elevation: "{elevation.none}"

  button-secondary:
    width: "full"
    height: 48
    background: "{colors.surface-paper}"
    color: "{colors.ink}"
    typography: "{typography.body-medium}"
    borderRadius: "{rounded.md}"
    border: "1.5px solid {colors.hairline-strong}"
    elevation: "{elevation.none}"

  button-ghost:
    background: transparent
    color: "{colors.primary}"
    typography: "{typography.body-medium}"
    padding: "{spacing.sm} {spacing.md}"

  button-shutter: # Camera capture — the signature button
    size: 72
    borderRadius: "{rounded.full}"
    background: "{colors.surface-paper}"
    border: "4px solid {colors.on-primary}" # White outer ring on any bg
    innerCircle:
      size: 56
      background: "{colors.primary}"
      borderRadius: "{rounded.full}"
    elevation:
      offset: [0, 4]
      blur: 20
      color: "rgba(0, 0, 0, 0.30)"

  button-icon-circle:
    size: 40
    borderRadius: "{rounded.full}"

  button-icon-circle-on-cream:
    extends: "button-icon-circle"
    background: "{colors.surface-paper}"
    color: "{colors.ink}"
    elevation: "{elevation.paper-rest}"

  button-icon-circle-on-hero:
    extends: "button-icon-circle"
    background: "{colors.on-primary-15}"
    color: "{colors.on-primary}"

  # ─── FLOATING ACTION BUTTON (Capture) ──────────────────

  fab-capture:
    size: 60
    borderRadius: "{rounded.full}"
    background: "{colors.primary}"
    color: "{colors.on-primary}"
    icon: "camera, 26px"
    elevation: "{elevation.red-glow}"
    position: "bottom-right, margin: {spacing.xl}"

  # ─── INPUT FIELDS ──────────────────────────────────────

  input-field:
    width: "full"
    minHeight: 48
    background: "{colors.surface-input}"
    color: "{colors.ink}"
    typography: "{typography.body}"
    borderRadius: "{rounded.md}"
    border: "1px solid transparent"
    padding: "{spacing.sm} {spacing.md}"
    placeholderColor: "{colors.ink-muted}"

  input-field-focused:
    extends: "input-field"
    background: "{colors.surface-paper}"
    border: "1.5px solid {colors.primary}"
    focusRing: "0 0 0 3px {colors.primary-glow-10}"

  input-field-error:
    extends: "input-field"
    border: "1.5px solid {colors.error}"

  text-area:
    extends: "input-field"
    minHeight: 96
    maxLines: 5
    padding: "{spacing.md}"

  # ─── EMPTY STATE ───────────────────────────────────────

  empty-state:
    padding: "{spacing.xxxl} {spacing.xl}"
    layout: "Column, mainAxisAlignment: center, crossAxisAlignment: center, gap: {spacing.md}"
    children:
      illustration:
        size: 160 # Lottie or Rive
      title:
        typography: "{typography.h2}"
        color: "{colors.ink}"
        alignment: center
      description:
        typography: "{typography.body}"
        color: "{colors.ink-secondary}"
        alignment: center
        maxWidth: 280
      cta:
        marginTop: "{spacing.lg}"
        component: "{components.button-primary}"

  # ─── SECTION HEADER ────────────────────────────────────

  section-header:
    padding: "{spacing.lg} 0 {spacing.md}"
    layout: "Row, mainAxisAlignment: spaceBetween, crossAxisAlignment: baseline"
    title:
      typography: "{typography.h2}"
      color: "{colors.ink}"
    action:
      typography: "{typography.body-medium}"
      color: "{colors.primary}"

  # ─── STATS CARD (on-this-day, milestones) ─────────────

  stats-card:
    background: "{colors.surface-paper}"
    borderRadius: "{rounded.lg}"
    padding: "{spacing.lg}"
    elevation: "{elevation.paper-rest}"
    layout: "Column, gap: {spacing.xs}"
    children:
      label:
        typography: "{typography.label}"
        color: "{colors.ink-muted}"
      value:
        typography: "{typography.h1}"
        color: "{colors.ink}"
      trend:
        typography: "{typography.caption}"
        color: "{colors.success-text}"

  # ─── BOTTOM NAVIGATION ────────────────────────────────

  bottom-nav:
    position: "fixed, bottom: 0"
    height: 64
    paddingBottom: "safe-area (34px fallback)"
    background: "{colors.surface-paper}"
    borderTop: "1px solid {colors.hairline}"
    elevation: "{elevation.bottom-bar-up}"
    layout: "Row, mainAxisAlignment: spaceAround"
    children:
      tab:
        flex: 1
        layout: "Column, gap: 2, mainAxisAlignment: center"
        icon:
          size: 24
        label:
          typography: "{typography.micro}"
      tab-inactive:
        icon-color: "{colors.ink-muted}"
        label-color: "{colors.ink-muted}"
      tab-active:
        icon-color: "{colors.primary}"
        label-color: "{colors.primary}"
        label-fontWeight: 600

  # ─── BOTTOM SHEET ─────────────────────────────────────

  bottom-sheet:
    background: "{colors.surface-paper}"
    borderRadius: "{rounded.xl} {rounded.xl} 0 0"
    padding: "{spacing.md} {spacing.md} {spacing.xxl}"
    elevation: "{elevation.sheet}"
    children:
      grabber:
        width: 40
        height: 4
        borderRadius: "{rounded.pill}"
        background: "{colors.hairline-strong}"
        alignment: center
        marginBottom: "{spacing.md}"

  # ─── SNACKBAR / TOAST ──────────────────────────────────

  snackbar:
    background: "{colors.ink}"
    color: "{colors.on-primary}"
    typography: "{typography.body-medium}"
    borderRadius: "{rounded.md}"
    padding: "{spacing.sm} {spacing.md}"
    margin: "{spacing.md}"
    elevation: "{elevation.paper-float}"

  # ─── SYNC STATUS INDICATOR ────────────────────────────

  sync-badge:
    position: "top-right of stub"
    size: 12
    borderRadius: "{rounded.full}"
    unsynced:
      background: "{colors.warning}"
      pulse: true
    syncing:
      background: "{colors.info}"
      rotate: true
    synced:
      visible: false # Hide when synced (default state)
---
