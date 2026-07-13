import 'package:flutter/material.dart';

import '../models/ticket.dart';
import 'wallet_ticket_card.dart';

/// Vertical scrolling list of wallet ticket cards.
/// Cards are shown one after another with breathing room between them.
class WalletStackView extends StatelessWidget {
  final List<Ticket> tickets;
  final void Function(Ticket) onTap;
  final EdgeInsetsGeometry padding;

  const WalletStackView({
    super.key,
    required this.tickets,
    required this.onTap,
    this.padding = const EdgeInsets.fromLTRB(20, 16, 20, 32),
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: padding,
      itemCount: tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (context, i) {
        final t = tickets[i];
        return WalletTicketCard(ticket: t, onTap: () => onTap(t));
      },
    );
  }
}
