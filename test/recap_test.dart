import 'package:flutter_test/flutter_test.dart';

import 'package:application/models/recap.dart';
import 'package:application/models/ticket.dart';

Ticket _t({
  required String id,
  required DateTime date,
  TicketCategory category = TicketCategory.everyday,
  String venue = '',
  int rating = 0,
}) =>
    Ticket(
      id: id,
      ticketNumber: '#$id',
      title: 't$id',
      category: category,
      date: date,
      venue: venue,
      imagePath: null,
      note: '',
      rating: rating,
      favorite: false,
      lat: null,
      lng: null,
      createdAt: date,
    );

void main() {
  test('empty year', () {
    final r = buildRecap([], 2026);
    expect(r.isEmpty, isTrue);
    expect(r.topCategory, isNull);
    expect(r.mostMemorable, isNull);
  });

  test('aggregates category, venue, month and most-memorable', () {
    final tickets = [
      _t(id: '1', date: DateTime(2026, 2, 1), category: TicketCategory.concert, venue: 'Ball Arena', rating: 3),
      _t(id: '2', date: DateTime(2026, 2, 10), category: TicketCategory.concert, venue: 'Ball Arena', rating: 5),
      _t(id: '3', date: DateTime(2026, 6, 1), category: TicketCategory.everyday, rating: 5),
      _t(id: '4', date: DateTime(2025, 1, 1), category: TicketCategory.concert), // other year
    ];
    final r = buildRecap(tickets, 2026);
    expect(r.total, 3);
    expect(r.topCategory, TicketCategory.concert);
    expect(r.topCategoryCount, 2);
    expect(r.topVenue, 'Ball Arena');
    // rating tie (5 vs 5) -> most recent wins: id 3 is June, id 2 is Feb
    expect(r.mostMemorable!.id, '3');
    expect(r.byMonth[2], 2);
    expect(r.byMonth[6], 1);
  });
}
