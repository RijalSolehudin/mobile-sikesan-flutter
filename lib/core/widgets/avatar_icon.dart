import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class MosqueAvatar extends StatelessWidget {
  final double size;
  final bool hasBorder;

  const MosqueAvatar({
    super.key,
    this.size = 44,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: hasBorder ? Border.all(color: Colors.white.withValues(alpha: 0.8), width: 2) : null,
      ),
      child: Center(
        child: Icon(
          Icons.mosque_rounded,
          size: size * 0.6,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
