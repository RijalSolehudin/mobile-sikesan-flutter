import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/avatar_icon.dart';

class ProfileHeader extends StatelessWidget {
  final String userName;
  final String userRole;
  final VoidCallback? onEditPhoto;

  const ProfileHeader({
    super.key,
    required this.userName,
    required this.userRole,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            child: Column(
              children: [
                // Title
                Center(
                  child: Text(
                    'PROFIL SAYA',
                    style: AppTypography.headerTitle.copyWith(
                      fontSize: 16,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Avatar with Camera Edit Badge
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const MosqueAvatar(size: 90),
                    GestureDetector(
                      onTap: onEditPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User name & Role badge
                Text(
                  userName,
                  style: AppTypography.headerTitle.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    userRole,
                    style: AppTypography.badgeText.copyWith(
                      color: Colors.white,
                      letterSpacing: 1.1,
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
