import 'package:flutter/material.dart';

class SplashBrandIcon extends StatelessWidget {
  final double size;
  final Animation<double>? scaleAnimation;
  final Animation<double>? fadeAnimation;

  const SplashBrandIcon({
    super.key,
    this.size = 76,
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
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF059669).withValues(alpha: 0.18),
            blurRadius: 24,
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
      padding: EdgeInsets.all(size * 0.11),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size * 0.22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF10B981), Color(0xFF059669), Color(0xFF047857)],
          ),
        ),
        child: Icon(
          Icons.account_balance_wallet_rounded,
          color: Colors.white,
          size: size * 0.42,
        ),
      ),
    );

    if (scaleAnimation != null) {
      iconContent = ScaleTransition(scale: scaleAnimation!, child: iconContent);
    }

    if (fadeAnimation != null) {
      iconContent = FadeTransition(opacity: fadeAnimation!, child: iconContent);
    }

    return iconContent;
  }
}
