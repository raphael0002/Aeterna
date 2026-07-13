import 'package:flutter_test/flutter_test.dart';

import 'package:application/models/ticket.dart';
import 'package:application/screens/calendar_screen.dart';
import 'package:application/screens/map_screen.dart';

Ticket _t({
  required String id,
  required DateTime date,
  double? lat,
  double? lng,
}) =>
    Ticket(
      id: id,
      ticketNumber: '#$id',
      title: 't$id',
      category: TicketCategory.everyday,
      date: date,
      venue: '',
      imagePath: null,
      note: '',
      rating: 0,
      favorite: false,
      lat: lat,
      lng: lng,
      createdAt: date,
    );

void main() {
  group('calendar', () {
    final tickets = [
      _t(id: '1', date: DateTime(2026, 3, 5)),
      _t(id: '2', date: DateTime(2026, 3, 5)), // same day
      _t(id: '3', date: DateTime(2026, 3, 20)),
      _t(id: '4', date: DateTime(2026, 7, 1)),
      _t(id: '5', date: DateTime(2025, 7, 1)), // other year
    ];

    test('countsByDay groups by calendar day', () {
      final c = countsByDay(tickets);
      expect(c[DateTime(2026, 3, 5)], 2);
      expect(c[DateTime(2026, 3, 20)], 1);
      expect(c[DateTime(2026, 7, 1)], 1);
    });

    test('busiestMonth picks the month with most events in the year', () {
      expect(busiestMonth(tickets, 2026), 3); // March has 3
      expect(busiestMonth(tickets, 2025), 7);
      expect(busiestMonth(tickets, 2000), isNull);
    });
  });

  group('map', () {
    test('journeyPath is chronological and skips unlocated tickets', () {
      final tickets = [
        _t(id: 'b', date: DateTime(2026, 5, 1), lat: 2, lng: 2),
        _t(id: 'a', date: DateTime(2026, 1, 1), lat: 1, lng: 1),
        _t(id: 'none', date: DateTime(2026, 3, 1)), // no location
        _t(id: 'c', date: DateTime(2026, 9, 1), lat: 3, lng: 3),
      ];
      final path = journeyPath(tickets);
      expect(path.map((p) => p.latitude), [1, 2, 3]); // sorted by date
    });
  });
}
