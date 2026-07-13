import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:application/data/ticket_store.dart';
import 'package:application/models/ticket.dart';
import 'package:application/providers/ticket_store_provider.dart';
import 'package:application/screens/wallet_screen.dart';
import 'package:application/theme/app_theme.dart';
import 'package:application/widgets/ticket_stub.dart';

Ticket _sample() => Ticket(
      id: '1',
      ticketNumber: '#12345',
      title: 'Radiohead — Live in Denver',
      category: TicketCategory.concert,
      date: DateTime(2026, 9, 14),
      venue: 'Ball Arena',
      imagePath: null,
      note: 'Unforgettable night.',
      rating: 4,
      favorite: false,
      lat: null,
      lng: null,
      createdAt: DateTime(2026, 9, 14),
    );

void main() {
  // No network in tests — use bundled fallback fonts instead of fetching.
  GoogleFonts.config.allowRuntimeFetching = false;

  Widget wrap(TicketStore store, {bool dark = false}) => ProviderScope(
        overrides: [
          ticketStoreProvider.overrideWith((ref) => store),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          darkTheme: buildAppTheme(dark: true),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: const WalletScreen(),
        ),
      );

  testWidgets('empty wallet shows the empty state', (tester) async {
    await tester.pumpWidget(wrap(TicketStore())); // empty store

    expect(find.text('My Stubs'), findsOneWidget);
    expect(find.text('Your first ticket is waiting.'), findsOneWidget);
    expect(find.text('New stub'), findsOneWidget);
  });

  testWidgets('dark theme provides CanvasColors and renders', (tester) async {
    await tester.pumpWidget(wrap(TicketStore(), dark: true));
    // no null-ext crash on CanvasColors
    expect(find.text('Your first ticket is waiting.'), findsOneWidget);
  });

  // Regression: stubs must render under unbounded height (ListView / scroll).
  testWidgets('stub front + back render in an unbounded list', (tester) async {
    final t = _sample();
    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: ListView(
          children: [TicketStub(ticket: t), TicketStubBack(ticket: t)],
        ),
      ),
    ));
    expect(tester.takeException(), isNull);
    expect(find.text('Radiohead — Live in Denver'), findsWidgets);
  });
}
