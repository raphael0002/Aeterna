// lib/screens/onboarding_screen.dart
import 'package:amicons/amicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_theme.dart';

// ── Slide data ────────────────────────────────────────────────────
class _Slide {
  final String? lottiePath;
  final IconData icon;
  final String title;
  final String body;

  const _Slide({
    this.lottiePath,
    required this.icon,
    required this.title,
    required this.body,
  });
}

const _slides = <_Slide>[
  _Slide(
    // TODO: Replace with your downloaded Lottie file
    lottiePath:
        "assets/lottie/onboarding_ticket.json", // 'assets/lottie/onboarding_ticket.json',
    icon: Amicons.iconly_ticket_fill,
    title: 'Every moment,\na keepsake',
    body:
        'Turn your photos into collectible ticket stubs — '
        'little objects that prove you were there.',
  ),
  _Slide(
    lottiePath:
        "assets/lottie/onboarding_location.json", // 'assets/lottie/onboarding_location.json',
    icon: Amicons.iconly_location_fill,
    title: 'Context,\ncaptured',
    body:
        'Date, place and details fill themselves from the photo, '
        'so saving a memory takes seconds.',
  ),
  _Slide(
    lottiePath:
        "assets/lottie/onboarding_collection.json", // 'assets/lottie/onboarding_collection.json',
    icon: Amicons.iconly_category_fill,
    title: 'Your collection\ngrows',
    body:
        'Flip through your tickets, search by place or tag, '
        'and relive the moments that matter.',
  ),
];

// ═══ SCREEN ══════════════════════════════════════════════════════
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const OnboardingScreen({super.key, required this.onDone});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _controller = PageController();
  int _page = 0;

  bool get _last => _page == _slides.length - 1;

  late final List<AnimationController> _lottieControllers;

  @override
  void initState() {
    super.initState();
    _lottieControllers = List.generate(
      _slides.length,
      (_) => AnimationController(vsync: this),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    for (final c in _lottieControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() {
    HapticFeedback.lightImpact();
    if (_last) {
      widget.onDone();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 360),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _onPageChanged(int i) {
    setState(() => _page = i);
    final ctrl = _lottieControllers[i];
    ctrl.reset();
    ctrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 12, 0),
                child: TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.onDone();
                  },
                  child: Text(
                    'Skip',
                    style: AppType.body.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: _onPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (_, i) => _SlideView(
                  slide: _slides[i],
                  animController: _lottieControllers[i],
                  isActive: i == _page,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _page ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page
                            ? AppColors.primary
                            : AppColors.borderStrong,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      _last ? 'Get started' : 'Next',
                      key: ValueKey(_last),
                      style: AppType.button.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══ SLIDE VIEW ══════════════════════════════════════════════════
class _SlideView extends StatelessWidget {
  final _Slide slide;
  final AnimationController animController;
  final bool isActive;

  const _SlideView({
    required this.slide,
    required this.animController,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            height: 200,
            child: slide.lottiePath != null
                ? _LottieIllustration(
                    path: slide.lottiePath!,
                    controller: animController,
                    isActive: isActive,
                  )
                : _IconPlaceholder(icon: slide.icon, isActive: isActive),
          ),
          const SizedBox(height: 40),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppType.h1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: AppType.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══ LOTTIE ILLUSTRATION ═════════════════════════════════════════
class _LottieIllustration extends StatelessWidget {
  final String path;
  final AnimationController controller;
  final bool isActive;

  const _LottieIllustration({
    required this.path,
    required this.controller,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isActive ? 1.0 : 0.4,
      child: Lottie.asset(
        path,
        controller: controller,
        onLoaded: (composition) {
          controller.duration = composition.duration;
          if (isActive) {
            controller.reset();
            controller.forward();
          }
        },
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Lottie load error for $path: $error');
          return _StaticIconFallback(icon: Amicons.iconly_ticket_fill);
        },
      ),
    );
  }
}

// ═══ ICON PLACEHOLDER (animated pulse) ═══════════════════════════
class _IconPlaceholder extends StatefulWidget {
  final IconData icon;
  final bool isActive;

  const _IconPlaceholder({required this.icon, required this.isActive});

  @override
  State<_IconPlaceholder> createState() => _IconPlaceholderState();
}

class _IconPlaceholderState extends State<_IconPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scaleAnim = Tween(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _glowAnim = Tween(
      begin: 0.06,
      end: 0.14,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: widget.isActive ? 1.0 : 0.4,
      child: ListenableBuilder(
        listenable: _pulseCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnim.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: _glowAnim.value),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(
                      alpha: _glowAnim.value * 0.6,
                    ),
                    blurRadius: 40,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.12),
            ),
            child: Icon(widget.icon, size: 52, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}

// ═══ STATIC ICON FALLBACK (Lottie error) ═════════════════════════
class _StaticIconFallback extends StatelessWidget {
  final IconData icon;

  const _StaticIconFallback({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.10),
      ),
      child: Center(
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.12),
          ),
          child: Icon(icon, size: 52, color: AppColors.primary),
        ),
      ),
    );
  }
}
