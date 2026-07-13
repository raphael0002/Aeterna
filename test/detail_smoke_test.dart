import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:application/data/ticket_store.dart';
import 'package:application/models/ticket.dart';
import 'package:application/providers/ticket_store_provider.dart';
import 'package:application/screens/ticket_detail_screen.dart';
import 'package:application/theme/app_theme.dart';

/// Fake store — returns a fixed ticket from byId, no disk (path_provider hangs
/// in flutter_test).
class _FakeStore extends TicketStore {
  final Ticket ticket;
  _FakeStore(this.ticket);
  @override
  Ticket? byId(String id) => ticket;
}

Ticket _sample() => Ticket(
      id: '1',
      ticketNumber: '#12345',
      title: 'Radiohead — Live in Denver',
      category: TicketCategory.concert,
      date: DateTime(2026, 9, 14),
      venue: 'Ball Arena',
      imagePath: null,
      note: 'Unforgettable.',
      rating: 4,
      favorite: false,
      lat: null,
      lng: null,
      createdAt: DateTime(2026, 9, 14),
    );

void main() {
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('boarding-pass detail renders without exception', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ticketStoreProvider.overrideWith((ref) => _FakeStore(_sample())),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const TicketDetailScreen(ticketId: '1'),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Radiohead — Live in Denver'), findsOneWidget);
    expect(find.text('Boarding pass'), findsOneWidget);
    expect(find.text('Ball Arena'), findsOneWidget);
  });
}
