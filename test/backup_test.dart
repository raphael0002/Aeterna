import 'package:flutter_test/flutter_test.dart';

import 'package:application/data/backup.dart';
import 'package:application/models/ticket.dart';

Ticket _t(String id) => Ticket(
      id: id,
      ticketNumber: '#$id',
      title: 'Title $id',
      category: TicketCategory.concert,
      date: DateTime(2026, 5, 1),
      venue: 'Venue',
      imagePath: null, // no file IO in tests
      note: 'note',
      rating: 3,
      favorite: true,
      lat: 1.5,
      lng: 2.5,
      createdAt: DateTime(2026, 5, 1),
    );

void main() {
  test('encode -> parse roundtrip preserves fields (minus device path)',
      () async {
    final json = await encodeBackup([_t('1'), _t('2')]);
    final entries = parseBackup(json);
    expect(entries.length, 2);
    expect(entries.first['title'], 'Title 1');
    expect(entries.first['favorite'], true);
    expect(entries.first['lat'], 1.5);
    expect(entries.first.containsKey('imagePath'), isFalse); // stripped
  });

  test('parseBackup rejects a foreign file', () {
    expect(() => parseBackup('{"app":"something_else","tickets":[]}'),
        throwsFormatException);
    expect(() => parseBackup('not json at all'), throwsA(isA<Exception>()));
  });
}
