import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widget/splash_brand_icon.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _iconScaleAnim;
  late final Animation<double> _iconFadeAnim;
  late final Animation<double> _glowScaleAnim;
  late final Animation<double> _textFadeAnim;
  late final Animation<Offset> _textSlideAnim;
  late final Animation<double> _subtitleFadeAnim;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    // Icon scale: spring bounce entry
    _iconScaleAnim = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.70, curve: Curves.easeOutBack),
      ),
    );

    // Icon fade: quick smooth opacity
    _iconFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    // Background glow ring expansion
    _glowScaleAnim = Tween<double>(begin: 0.4, end: 1.25).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.1, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    // Title slide & fade
    _textFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.40, 0.85, curve: Curves.easeOut),
      ),
    );

    _textSlideAnim =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.40, 0.85, curve: Curves.easeOutCubic),
          ),
        );

    // Subtitle fade
    _subtitleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOut),
      ),
    );

    _animController.forward();
    _startTransition();
  }

  void _startTransition() {
    // Show splash for 2.0 seconds, then navigate based on auth state
    _timer = Timer(const Duration(milliseconds: 2000), () async {
      if (!mounted) return;

      final authBloc = context.read<AuthBloc>();
      // If auth is still checking initial token, wait briefly
      if (authBloc.state is AuthInitial) {
        try {
          await authBloc.stream
              .firstWhere((state) => state is! AuthInitial)
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
      }

      if (!mounted) return;

      if (authBloc.state.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/role-selection');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF2FAF6), Color(0xFFE8F7F0)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Subtle emerald pulse glow behind icon during entry
                    AnimatedBuilder(
                      animation: _animController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: ((1.0 - _animController.value) * 0.4).clamp(
                            0.0,
                            1.0,
                          ),
                          child: Transform.scale(
                            scale: _glowScaleAnim.value,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(
                                  0xFF059669,
                                ).withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    SplashBrandIcon(
                      scaleAnimation: _iconScaleAnim,
                      fadeAnimation: _iconFadeAnim,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _textSlideAnim,
                  child: FadeTransition(
                    opacity: _textFadeAnim,
                    child: Text(
                      'SIKESAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF064E3B),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                FadeTransition(
                  opacity: _subtitleFadeAnim,
                  child: Text(
                    'Sistem Keuangan Santri',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
