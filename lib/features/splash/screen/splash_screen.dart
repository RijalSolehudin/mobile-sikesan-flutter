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

  // Icon animations: fade + slide popup from bottom + scale pop
  late final Animation<double> _iconFadeAnim;
  late final Animation<Offset> _iconSlideAnim;
  late final Animation<double> _iconScaleAnim;

  // Title animations: fade + slide popup from bottom
  late final Animation<double> _titleFadeAnim;
  late final Animation<Offset> _titleSlideAnim;

  // Subtitle animations: fade + slide popup from bottom
  late final Animation<double> _subtitleFadeAnim;
  late final Animation<Offset> _subtitleSlideAnim;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 1. Icon animations (pops up from bottom with spring bounce)
    _iconFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.40, curve: Curves.easeIn),
      ),
    );

    _iconSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.65), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
          ),
        );

    _iconScaleAnim = Tween<double>(begin: 0.70, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    // 2. Title "SIKESAN" animations (staggered slide popup from bottom)
    _titleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.18, 0.60, curve: Curves.easeIn),
      ),
    );

    _titleSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.70), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.18, 0.78, curve: Curves.easeOutBack),
          ),
        );

    // 3. Subtitle "Sistem Keuangan Santri" animations (staggered smooth slide up)
    _subtitleFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.30, 0.72, curve: Curves.easeIn),
      ),
    );

    _subtitleSlideAnim =
        Tween<Offset>(begin: const Offset(0.0, 0.70), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.30, 0.90, curve: Curves.easeOutCubic),
          ),
        );

    _animController.forward();
    _startTransition();
  }

  void _startTransition() {
    // Show splash screen for 2.2 seconds to allow smooth branding presentation
    _timer = Timer(const Duration(milliseconds: 2200), () async {
      if (!mounted) return;

      final authBloc = context.read<AuthBloc>();
      // Wait if auth check is still pending
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
      backgroundColor: const Color(0xFFE8F8F2),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFFE8F8F2)),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Icon with Fade + Slide Popup + Scale
                SplashBrandIcon(
                  size: 84,
                  slideAnimation: _iconSlideAnim,
                  scaleAnimation: _iconScaleAnim,
                  fadeAnimation: _iconFadeAnim,
                ),
                const SizedBox(height: 22),

                // Title "SIKESAN" with Fade + Slide Popup
                SlideTransition(
                  position: _titleSlideAnim,
                  child: FadeTransition(
                    opacity: _titleFadeAnim,
                    child: Text(
                      'SIKESAN',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF064E3B),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle "Sistem Keuangan Santri" with Fade + Slide
                SlideTransition(
                  position: _subtitleSlideAnim,
                  child: FadeTransition(
                    opacity: _subtitleFadeAnim,
                    child: Text(
                      'Sistem Keuangan Santri',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF234F40),
                        letterSpacing: 0.2,
                      ),
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
