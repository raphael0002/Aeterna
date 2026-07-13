import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../providers/ticket_store_provider.dart';
import '../screens/home_shell.dart';
import '../screens/location_picker_screen.dart';
import '../screens/recap_screen.dart';
import '../screens/share_screen.dart';
import '../screens/ticket_detail_screen.dart';
import '../screens/ticket_form_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeShell()),
    GoRoute(
      path: '/new',
      builder: (context, state) {
        final container = ProviderScope.containerOf(context);
        final store = container.read(ticketStoreProvider);
        return TicketFormScreen(store: store);
      },
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final container = ProviderScope.containerOf(context);
        final store = container.read(ticketStoreProvider);
        final id = state.pathParameters['id']!;
        final ticket = store.byId(id);
        return TicketFormScreen(store: store, existing: ticket);
      },
    ),
    GoRoute(
      path: '/ticket/:id',
      builder: (_, s) => TicketDetailScreen(ticketId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/share/:id',
      builder: (context, state) {
        final container = ProviderScope.containerOf(context);
        final store = container.read(ticketStoreProvider);
        final id = state.pathParameters['id']!;
        final ticket = store.byId(id);
        if (ticket == null) return const Scaffold();
        return ShareScreen(ticket: ticket);
      },
    ),
    GoRoute(
      path: '/recap',
      builder: (context, _) {
        final container = ProviderScope.containerOf(context);
        final store = container.read(ticketStoreProvider);
        return RecapScreen(store: store, year: DateTime.now().year);
      },
    ),
    GoRoute(
      path: '/pick-location',
      builder: (_, s) => LocationPickerScreen(initial: s.extra as LatLng?),
    ),
  ],
);
