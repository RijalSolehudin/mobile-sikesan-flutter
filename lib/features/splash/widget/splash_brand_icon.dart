import 'package:flutter/material.dart';

class SplashBrandIcon extends StatelessWidget {
  final double size;
  final Animation<Offset>? slideAnimation;
  final Animation<double>? scaleAnimation;
  final Animation<double>? fadeAnimation;

  const SplashBrandIcon({
    super.key,
    this.size = 84,
    this.slideAnimation,
    this.scaleAnimation,
    this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconContent = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.12),
            blurRadius: 28,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.09),
      child: Image.asset(
        'assets/images/logo_icon.png',
        fit: BoxFit.contain,
      ),
    );

    if (scaleAnimation != null) {
      iconContent = ScaleTransition(scale: scaleAnimation!, child: iconContent);
    }

    if (slideAnimation != null) {
      iconContent = SlideTransition(
        position: slideAnimation!,
        child: iconContent,
      );
    }

    if (fadeAnimation != null) {
      iconContent = FadeTransition(opacity: fadeAnimation!, child: iconContent);
    }

    return iconContent;
  }
}
