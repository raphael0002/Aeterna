import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: MemoryTicketApp()));
}

class MemoryTicketApp extends StatelessWidget {
  const MemoryTicketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Aeterna',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      darkTheme: buildAppTheme(dark: true),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      builder: (context, child) {
        // Clamp text scaling
        final mq = MediaQuery.of(context);
        final scaled = MediaQuery(
          data: mq.copyWith(
            textScaler: mq.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.15,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
        // One-shot fade-in over cream: smooth reveal as the native splash
        // (rust logo on cream) hands off to the app — no hard cut.
        return ColoredBox(
          color: AppColors.canvas,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 450),
            curve: Curves.easeOut,
            child: scaled,
            builder: (_, value, child) =>
                Opacity(opacity: value, child: child),
          ),
        );
      },
    );
  }
}
