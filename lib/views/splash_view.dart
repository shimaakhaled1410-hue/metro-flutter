import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metro/views/welcome_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _subtitleSlide;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _loaderFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Logo: pops in with a gentle overshoot, 0 -> 45%
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    // Title: slides up + fades in, 25% -> 60%
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _titleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );

    // Subtitle: same treatment, slightly delayed, 35% -> 70%
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );

    // Loader: fades in last, 55% -> 80%
    _loaderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
    );

    _controller.forward();

    // Navigate once the intro has fully played + a short hold, instead of
    // a second, unrelated timer running in parallel with the animation.
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Get.off(
              () => const WelcomeView(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 800),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [const Color(0xFF121212), const Color(0xFF1A1A1A)]
                    : [Colors.white, const Color(0xFFF5F6F8)],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withValues(alpha: isDark ? 0.4 : 0.12),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeTransition(
                    opacity: _titleFade,
                    child: SlideTransition(
                      position: _titleSlide,
                      child: Text(
                        'metro_title'.tr,
                        style: const TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _subtitleFade,
                    child: SlideTransition(
                      position: _subtitleSlide,
                      child: Text(
                        'your_metro_guide'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  FadeTransition(
                    opacity: _loaderFade,
                    child: _PulsingDots(color: subtitleColor ?? Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// A small, modern three-dot loader that pulses in sequence,
/// replacing the plain [CircularProgressIndicator].
class _PulsingDots extends StatefulWidget {
  final Color color;
  const _PulsingDots({required this.color});

  @override
  State<_PulsingDots> createState() => _PulsingDotsState();
}

class _PulsingDotsState extends State<_PulsingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final t = (_controller.value - delay) % 1.0;
            final scale = 0.5 + 0.5 * (1 - (2 * t - 1).abs());
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale.clamp(0.5, 1.0),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}