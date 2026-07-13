import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/ticket_store.dart';

final ticketStoreProvider = ChangeNotifierProvider<TicketStore>((ref) {
  final store = TicketStore();
  store.load();
  return store;
});
