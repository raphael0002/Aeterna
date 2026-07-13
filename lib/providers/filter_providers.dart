import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ticket.dart';

/// Shared category filter for the wallet screen.
/// `null` means "All categories".
///
/// Driven by:
/// - Category chips in the wallet hero
/// - The dynamic FAB "Filter" action in the floating nav (if wired)
///
/// Read by:
/// - Wallet screen (filters the ticket list)
/// - Any future gallery / recap screens
final categoryFilterProvider = StateProvider<TicketCategory?>((ref) => null);

/// Shared "starred only" toggle for the wallet screen.
/// When `true`, only tickets marked as favorite are shown.
///
/// Driven by:
/// - Star icon button in the wallet hero top-right
///
/// Read by:
/// - Wallet screen
final starredOnlyProvider = StateProvider<bool>((ref) => false);

/// Optional: full-text search query (empty = no search).
/// Not wired to a screen yet, but ready for a future search bar.
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Optional: year filter for the wallet / recap.
/// `null` means "all years".
final yearFilterProvider = StateProvider<int?>((ref) => null);
