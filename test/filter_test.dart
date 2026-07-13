import 'package:flutter_test/flutter_test.dart';

import 'package:application/models/ticket.dart';
import 'package:application/screens/wallet_screen.dart';

Ticket _t({
  required String id,
  String title = '',
  String venue = '',
  String note = '',
  TicketCategory category = TicketCategory.everyday,
  bool favorite = false,
  DateTime? date,
  double? lat,
  double? lng,
}) =>
    Ticket(
      id: id,
      ticketNumber: '#$id',
      title: title,
      category: category,
      date: date ?? DateTime(2026, 1, 1),
      venue: venue,
      imagePath: null,
      note: note,
      rating: 0,
      favorite: favorite,
      lat: lat,
      lng: lng,
      createdAt: DateTime(2026, 1, 1),
    );

void main() {
  final data = [
    _t(id: '1', title: 'Radiohead', venue: 'Ball Arena', category: TicketCategory.concert, favorite: true),
    _t(id: '2', title: 'Lakers game', venue: 'Crypto Arena', category: TicketCategory.milestone),
    _t(id: '3', title: 'Dune', note: 'IMAX in denver', category: TicketCategory.everyday),
  ];

  test('no filters returns everything', () {
    expect(filterTickets(data).length, 3);
  });

  test('category filter', () {
    final r = filterTickets(data, category: TicketCategory.milestone);
    expect(r.map((t) => t.id), ['2']);
  });

  test('starred filter', () {
    expect(filterTickets(data, starredOnly: true).map((t) => t.id), ['1']);
  });

  test('query matches title, venue and note, case-insensitively', () {
    expect(filterTickets(data, query: 'arena').map((t) => t.id), ['1', '2']);
    expect(filterTickets(data, query: 'DENVER').map((t) => t.id), ['3']);
    expect(filterTickets(data, query: 'radiohead').map((t) => t.id), ['1']);
  });

  test('filters combine (AND)', () {
    final r = filterTickets(data, query: 'arena', category: TicketCategory.concert);
    expect(r.map((t) => t.id), ['1']);
  });
}
