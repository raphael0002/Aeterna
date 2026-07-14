import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ticket_template.dart';

String ticketDeepLink(String id) => 'memoryticket://ticket/$id';

/// design.md category color code: amber / teal / coral / sage.
enum TicketCategory { concert, travel, milestone, everyday }

extension TicketCategoryX on TicketCategory {
  String get label => switch (this) {
        TicketCategory.concert => 'Concert',
        TicketCategory.travel => 'Travel',
        TicketCategory.milestone => 'Milestone',
        TicketCategory.everyday => 'Everyday',
      };

  Color get color => switch (this) {
        TicketCategory.concert => AppColors.catConcert,
        TicketCategory.travel => AppColors.catTravel,
        TicketCategory.milestone => AppColors.catMilestone,
        TicketCategory.everyday => AppColors.catEveryday,
      };

  /// Desaturated header/tag wash (~90% lighter parent).
  Color get bg => switch (this) {
        TicketCategory.concert => AppColors.catConcertBg,
        TicketCategory.travel => AppColors.catTravelBg,
        TicketCategory.milestone => AppColors.catMilestoneBg,
        TicketCategory.everyday => AppColors.catEverydayBg,
      };

  IconData get icon => switch (this) {
        TicketCategory.concert => Amicons.iconly_voice_fill,
        TicketCategory.travel => Amicons.iconly_discovery_fill,
        TicketCategory.milestone => Amicons.iconly_ticket_star_fill,
        TicketCategory.everyday => Amicons.iconly_activity_fill,
      };

  Color get lightBg => bg;
  Color get mediumBg => color.withValues(alpha: 0.16);
}

class Ticket {
  final String id;
  final String ticketNumber;
  final String title;
  final TicketCategory category;
  final DateTime date;
  final String venue;
  final String? imagePath;
  final String note;
  final int rating;
  final bool favorite;
  final double? lat;
  final double? lng;
  final List<String> tags;
  final TicketTemplate template;
  final DateTime createdAt;

  const Ticket({
    required this.id,
    required this.ticketNumber,
    required this.title,
    required this.category,
    required this.date,
    required this.venue,
    required this.imagePath,
    required this.note,
    required this.rating,
    required this.favorite,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.tags = const [],
    this.template = TicketTemplate.classic,
  });

  bool get hasLocation => lat != null && lng != null;
  bool get hasImage => imagePath != null && imagePath!.isNotEmpty;
  bool get hasNote => note.trim().isNotEmpty;

  Ticket copyWith({
    String? title,
    TicketCategory? category,
    DateTime? date,
    String? venue,
    String? imagePath,
    String? note,
    int? rating,
    bool? favorite,
    double? lat,
    double? lng,
    List<String>? tags,
    TicketTemplate? template,
  }) {
    return Ticket(
      id: id,
      ticketNumber: ticketNumber,
      title: title ?? this.title,
      category: category ?? this.category,
      date: date ?? this.date,
      venue: venue ?? this.venue,
      imagePath: imagePath ?? this.imagePath,
      note: note ?? this.note,
      rating: rating ?? this.rating,
      favorite: favorite ?? this.favorite,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      tags: tags ?? this.tags,
      template: template ?? this.template,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticketNumber': ticketNumber,
        'title': title,
        'category': category.name,
        'date': date.toIso8601String(),
        'venue': venue,
        'imagePath': imagePath,
        'note': note,
        'rating': rating,
        'favorite': favorite,
        'lat': lat,
        'lng': lng,
        'tags': tags,
        'template': template.name,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Ticket.fromJson(Map<String, dynamic> j) => Ticket(
        id: j['id'] as String,
        ticketNumber: j['ticketNumber'] as String? ?? '#00000',
        title: j['title'] as String,
        category: TicketCategory.values.firstWhere(
          (c) => c.name == j['category'],
          orElse: () => TicketCategory.everyday,
        ),
        date: DateTime.parse(j['date'] as String),
        venue: j['venue'] as String? ?? '',
        imagePath: j['imagePath'] as String?,
        note: j['note'] as String? ?? '',
        rating: (j['rating'] as num?)?.toInt() ?? 0,
        favorite: j['favorite'] as bool? ?? false,
        lat: (j['lat'] as num?)?.toDouble(),
        lng: (j['lng'] as num?)?.toDouble(),
        tags: (j['tags'] as List?)?.map((e) => e.toString()).toList() ??
            const [],
        template: templateFromName(j['template'] as String?),
        createdAt: DateTime.parse(
            j['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      );
}
