// lib/screens/home_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/floating_nav_bar.dart';
import 'calendar_screen.dart';
import 'map_screen.dart';
import 'search_screen.dart';
import 'wallet_screen.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _navIndex = 0;

  void _onNavTap(int i) {
    if (i == 2) {
      HapticFeedback.mediumImpact();
      context.push('/new');
      return;
    }
    if (i == _navIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _navIndex = i);
  }

  int get _stackIndex {
    if (_navIndex <= 1) return _navIndex;
    return _navIndex - 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: false,
      backgroundColor: const Color(0xFFFAF7F2),
      body: IndexedStack(
        index: _stackIndex,
        children: const [
          WalletScreen(),
          SearchScreen(),
          CalendarScreen(),
          MapScreen(),
        ],
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _navIndex,
        onTap: _onNavTap,
      ),
    );
  }
}
