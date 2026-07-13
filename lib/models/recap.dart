import 'ticket.dart';

class YearRecap {
  final int year;
  final int total;
  final TicketCategory? topCategory;
  final int topCategoryCount;
  final String? topVenue;
  final Ticket? mostMemorable;
  final Map<int, int> byMonth;

  const YearRecap({
    required this.year,
    required this.total,
    required this.topCategory,
    required this.topCategoryCount,
    required this.topVenue,
    required this.mostMemorable,
    required this.byMonth,
  });

  bool get isEmpty => total == 0;
}

YearRecap buildRecap(List<Ticket> all, int year) {
  final ts = all.where((t) => t.date.year == year).toList();

  final byCat = <TicketCategory, int>{};
  final byVenue = <String, int>{};
  final byMonth = <int, int>{};

  for (final t in ts) {
    byCat[t.category] = (byCat[t.category] ?? 0) + 1;
    byMonth[t.date.month] = (byMonth[t.date.month] ?? 0) + 1;
    final v = t.venue.trim();
    if (v.isNotEmpty) byVenue[v] = (byVenue[v] ?? 0) + 1;
  }

  TicketCategory? topCat;
  var topCatCount = 0;
  byCat.forEach((k, v) {
    if (v > topCatCount) {
      topCat = k;
      topCatCount = v;
    }
  });

  String? topVenue;
  var topVenueCount = 0;
  byVenue.forEach((k, v) {
    if (v > topVenueCount) {
      topVenue = k;
      topVenueCount = v;
    }
  });

  Ticket? memorable;
  for (final t in ts) {
    if (memorable == null ||
        t.rating > memorable.rating ||
        (t.rating == memorable.rating && t.date.isAfter(memorable.date))) {
      memorable = t;
    }
  }

  return YearRecap(
    year: year,
    total: ts.length,
    topCategory: topCat,
    topCategoryCount: topCatCount,
    topVenue: topVenue,
    mostMemorable: memorable,
    byMonth: byMonth,
  );
}
