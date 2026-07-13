import 'package:flutter/material.dart';

class FoilSeal extends StatefulWidget {
  final double size;
  const FoilSeal({super.key, this.size = 40});

  @override
  State<FoilSeal> createState() => _FoilSealState();
}

class _FoilSealState extends State<FoilSeal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 6),
  );
  bool _started = false;

  static const _foil = [
    Color(0xFFE7A6C4),
    Color(0xFFEBD8A0),
    Color(0xFFA6DAC9),
    Color(0xFFB9A9E0),
    Color(0xFFE7A6C4),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _started = true;
      if (!MediaQuery.of(context).disableAnimations) _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _seal(double turn) => Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: SweepGradient(
            colors: _foil,
            transform: GradientRotation(turn * 6.283),
          ),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.7), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.verified_rounded,
          size: widget.size * 0.48,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).disableAnimations) return _seal(0.15);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => _seal(_c.value),
    );
  }
}
