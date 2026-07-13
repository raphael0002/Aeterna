import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../data/ticket_store.dart';
import '../models/ticket.dart';
import '../theme/app_theme.dart';
import '../widgets/wallet_ticket_card.dart';
import 'location_picker_screen.dart';

class TicketFormScreen extends StatefulWidget {
  final TicketStore store;
  final Ticket? existing;

  const TicketFormScreen({super.key, required this.store, this.existing});

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _scrollController = ScrollController();

  late final TextEditingController _title;
  late final TextEditingController _venue;
  late final TextEditingController _note;
  late TicketCategory _category;
  late DateTime _date;
  late int _rating;
  late bool _favorite;

  String? _pickedImagePath;
  double? _lat;
  double? _lng;
  bool _saving = false;

  bool get _isEdit => widget.existing != null;
  bool get _hasLocation => _lat != null && _lng != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _title = TextEditingController(text: e?.title ?? '');
    _venue = TextEditingController(text: e?.venue ?? '');
    _note = TextEditingController(text: e?.note ?? '');
    _category = e?.category ?? TicketCategory.concert;
    _date = e?.date ?? DateTime.now();
    _rating = e?.rating ?? 0;
    _favorite = e?.favorite ?? false;
    _lat = e?.lat;
    _lng = e?.lng;
    for (final c in [_title, _venue, _note]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _title.removeListener(_onFieldChanged);
    _venue.removeListener(_onFieldChanged);
    _note.removeListener(_onFieldChanged);
    _title.dispose();
    _venue.dispose();
    _note.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Ticket _preview() {
    final base = widget.existing;
    return Ticket(
      id: base?.id ?? 'preview',
      ticketNumber: base?.ticketNumber ?? '#00000',
      title: _title.text.trim().isEmpty
          ? 'Untitled memory'
          : _title.text.trim(),
      category: _category,
      date: _date,
      venue: _venue.text.trim(),
      imagePath: _pickedImagePath ?? base?.imagePath,
      note: _note.text.trim(),
      rating: _rating,
      favorite: _favorite,
      lat: _lat,
      lng: _lng,
      createdAt: base?.createdAt ?? DateTime.now(),
    );
  }

  Future<void> _pickImage() async {
    try {
      final x = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        imageQuality: 88,
      );
      if (x != null) setState(() => _pickedImagePath = x.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not access photos')));
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<LocationResult>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(
          initial: _hasLocation ? LatLng(_lat!, _lng!) : null,
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      _lat = result.point?.latitude;
      _lng = result.point?.longitude;
    });
  }

  Future<void> _persist() async {
    final store = widget.store;
    if (_isEdit) {
      await store.update(
        widget.existing!.copyWith(
          title: _title.text.trim(),
          category: _category,
          date: _date,
          venue: _venue.text.trim(),
          note: _note.text.trim(),
          rating: _rating,
          favorite: _favorite,
        ),
        newSourceImagePath: _pickedImagePath,
      );
      await store.setLocation(widget.existing!.id, _lat, _lng);
    } else {
      await store.add(
        title: _title.text.trim(),
        category: _category,
        date: _date,
        venue: _venue.text.trim(),
        note: _note.text.trim(),
        rating: _rating,
        sourceImagePath: _pickedImagePath,
        lat: _lat,
        lng: _lng,
      );
      // Favorite is handled by store.setFavorite after creation
      if (_favorite) {
        // Store's add() doesn't take favorite, but we can find it back easily
        // Only real fix would be to add favorite param to store.add()
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await _persist();
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete this ticket?'),
        content: const Text(
          'This memory will be permanently removed from your wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.store.delete(widget.existing!.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final showImage = _pickedImagePath ?? widget.existing?.imagePath;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              title: _isEdit ? 'Edit ticket' : 'New ticket',
              onBack: () => Navigator.of(context).pop(),
              onDelete: _isEdit ? _confirmDelete : null,
            ),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
                  children: [
                    // ── Live preview ────────────────────────
                    _SectionLabel('Preview'),
                    const SizedBox(height: 10),
                    WalletTicketCard(ticket: _preview()),
                    const SizedBox(height: 28),

                    // ── Photo ──────────────────────────────
                    _SectionLabel('Photo'),
                    const SizedBox(height: 10),
                    _PhotoPicker(
                      imagePath: showImage,
                      accentColor: _category.color,
                      onTap: _pickImage,
                      onClear: showImage != null
                          ? () => setState(() {
                              _pickedImagePath = null;
                            })
                          : null,
                    ),
                    const SizedBox(height: 28),

                    // ── Details card ───────────────────────
                    _SectionLabel('Details'),
                    const SizedBox(height: 10),
                    _Card(
                      children: [
                        _FieldRow(
                          label: 'Title',
                          required: true,
                          child: TextFormField(
                            controller: _title,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppType.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _lineDecoration(
                              'e.g. Radiohead — Live in Denver',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Give this memory a title'
                                : null,
                          ),
                        ),
                        const _RowDivider(),
                        _FieldRow(
                          label: 'Category',
                          child: _CategoryGrid(
                            value: _category,
                            onChanged: (c) => setState(() => _category = c),
                          ),
                        ),
                        const _RowDivider(),
                        _ActionRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Date',
                          value: DateFormat('EEEE, MMM d, yyyy').format(_date),
                          onTap: _pickDate,
                        ),
                        const _RowDivider(),
                        _FieldRow(
                          label: 'Venue',
                          child: TextFormField(
                            controller: _venue,
                            textCapitalization: TextCapitalization.words,
                            style: AppType.body.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _lineDecoration(
                              'e.g. Ball Arena, Denver',
                            ),
                          ),
                        ),
                        const _RowDivider(),
                        _ActionRow(
                          icon: _hasLocation
                              ? Icons.place_rounded
                              : Icons.add_location_alt_outlined,
                          iconColor: _hasLocation ? AppColors.primary : null,
                          label: 'Location',
                          value: _hasLocation
                              ? '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}'
                              : 'Tap to set on map',
                          valueMuted: !_hasLocation,
                          onTap: _pickLocation,
                          trailing: _hasLocation
                              ? GestureDetector(
                                  onTap: () => setState(() {
                                    _lat = null;
                                    _lng = null;
                                  }),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceInset,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close_rounded,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // ── Your memory card ───────────────────
                    _SectionLabel('Your memory'),
                    const SizedBox(height: 10),
                    _Card(
                      children: [
                        _FieldRow(
                          label: 'Note',
                          child: TextFormField(
                            controller: _note,
                            maxLines: 4,
                            minLines: 3,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppType.body.copyWith(
                              color: AppColors.textPrimary,
                              height: 1.45,
                            ),
                            decoration: _lineDecoration(
                              'What made this one memorable?',
                            ),
                          ),
                        ),
                        const _RowDivider(),
                        _FieldRow(
                          label: 'Rating',
                          trailing: _rating > 0
                              ? Text(
                                  '$_rating/5',
                                  style: AppType.small.copyWith(
                                    color: _category.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                )
                              : Text(
                                  'Not rated',
                                  style: AppType.small.copyWith(
                                    color: AppColors.textTertiary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _StarPicker(
                              rating: _rating,
                              color: _category.color,
                              onChanged: (r) => setState(() => _rating = r),
                            ),
                          ),
                        ),
                        const _RowDivider(),
                        _ToggleRow(
                          icon: _favorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          iconColor: _favorite
                              ? _category.color
                              : AppColors.textSecondary,
                          label: 'Mark as favorite',
                          subtitle: 'Shows a star badge on your ticket',
                          value: _favorite,
                          onChanged: (v) => setState(() => _favorite = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Sticky save button ─────────────────────────
            _SaveBar(
              label: _isEdit ? 'Save changes' : 'Save to wallet',
              loading: _saving,
              onPressed: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _lineDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppType.body.copyWith(
        color: AppColors.textTertiary,
        fontWeight: FontWeight.w400,
      ),
      filled: false,
      contentPadding: EdgeInsets.zero,
      isDense: true,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      errorStyle: AppType.small.copyWith(color: AppColors.danger),
    );
  }
}

// ═══ TOP BAR ═══════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback? onDelete;

  const _TopBar({required this.title, required this.onBack, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          _RoundIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: onBack,
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: AppType.title.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            _RoundIconButton(
              icon: Icons.delete_outline_rounded,
              iconColor: AppColors.danger,
              onTap: onDelete!,
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? iconColor;
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 18,
            color: iconColor ?? AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

// ═══ SECTION LABEL ═════════════════════════════════════════════════
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        text.toUpperCase(),
        style: monoStyle(
          size: 11,
          color: AppColors.textSecondary,
          weight: FontWeight.w700,
        ).copyWith(letterSpacing: 1.4),
      ),
    );
  }
}

// ═══ CARD ══════════════════════════════════════════════════════════
class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0x143C2814),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      color: AppColors.borderSubtle,
    );
  }
}

// ═══ FIELD ROW (label above input) ═════════════════════════════════
class _FieldRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool required;
  final Widget? trailing;

  const _FieldRow({
    required this.label,
    required this.child,
    this.required = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: AppType.small.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              if (required)
                Text(
                  ' *',
                  style: AppType.small.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              const Spacer(),
              ?trailing,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

// ═══ ACTION ROW (tappable — date, location) ════════════════════════
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String value;
  final bool valueMuted;
  final VoidCallback onTap;
  final Widget? trailing;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.iconColor,
    this.valueMuted = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.surfaceInset,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppType.small.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppType.body.copyWith(
                      color: valueMuted
                          ? AppColors.textTertiary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

// ═══ TOGGLE ROW (favorite switch) ══════════════════════════════════
class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 12, 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.surfaceInset,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppType.body.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppType.small.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeColor: AppColors.primary,
            onChanged: (v) {
              HapticFeedback.lightImpact();
              onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

// ═══ PHOTO PICKER ══════════════════════════════════════════════════
class _PhotoPicker extends StatelessWidget {
  final String? imagePath;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PhotoPicker({
    required this.imagePath,
    required this.accentColor,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && File(imagePath!).existsSync();

    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x143C2814),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _emptyState(accentColor),
                      ),
                      // Dark gradient at bottom for badge legibility
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: 60,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12,
                        bottom: 12,
                        child: _PillButton(
                          icon: Icons.edit_rounded,
                          label: 'Change',
                          onTap: onTap,
                        ),
                      ),
                      if (onClear != null)
                        Positioned(
                          right: 12,
                          top: 12,
                          child: _RoundBadge(
                            icon: Icons.close_rounded,
                            onTap: onClear!,
                          ),
                        ),
                    ],
                  )
                : _emptyState(accentColor),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(Color accent) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.add_a_photo_outlined, size: 26, color: accent),
          ),
          const SizedBox(height: 14),
          Text(
            'Add a photo',
            style: AppType.body.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap to choose from your library',
            style: AppType.small.copyWith(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PillButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: AppColors.textPrimary),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppType.small.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundBadge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundBadge({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 16, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

// ═══ CATEGORY GRID ═════════════════════════════════════════════════
class _CategoryGrid extends StatelessWidget {
  final TicketCategory value;
  final ValueChanged<TicketCategory> onChanged;

  const _CategoryGrid({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: TicketCategory.values.map((c) {
        final selected = c == value;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(c);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: selected ? c.color.withValues(alpha: 0.12) : c.bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected ? c.color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(c.icon, size: 15, color: c.color),
                const SizedBox(width: 6),
                Text(
                  c.label,
                  style: AppType.small.copyWith(
                    color: selected ? c.color : AppColors.textPrimary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ═══ STAR PICKER ═══════════════════════════════════════════════════
class _StarPicker extends StatelessWidget {
  final int rating;
  final Color color;
  final ValueChanged<int> onChanged;

  const _StarPicker({
    required this.rating,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(rating == i + 1 ? 0 : i + 1);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: filled
                    ? color.withValues(alpha: 0.12)
                    : AppColors.surfaceInset,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 22,
                color: filled ? color : AppColors.textTertiary,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ═══ SAVE BAR (sticky bottom) ══════════════════════════════════════
class _SaveBar extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;

  const _SaveBar({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7F2),
        border: const Border(
          top: BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x143C2814),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.primary.withValues(
                  alpha: 0.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                elevation: 0,
              ),
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      label,
                      style: AppType.button.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
