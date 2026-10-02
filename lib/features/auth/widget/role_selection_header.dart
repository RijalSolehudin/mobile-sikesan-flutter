import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionHeader extends StatelessWidget {
  const RoleSelectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Small Badge SIKESAN
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F7EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_rounded,
                size: 13,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 5),
              Text(
                'SIKESAN',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF059669),
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Title
        Text(
          'Pilih Role Anda',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),

        // Subtitle
        Text(
          'Silakan pilih peran sesuai hak akses untuk melanjutkan ke halaman login.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF64748B),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
