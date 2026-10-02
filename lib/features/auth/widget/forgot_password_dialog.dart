import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordDialog extends StatelessWidget {
  const ForgotPasswordDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const ForgotPasswordDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          const Icon(Icons.help_outline_rounded, color: Color(0xFF059669)),
          const SizedBox(width: 8),
          Text(
            'Lupa Password?',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Text(
        'Untuk alasan keamanan, silakan hubungi bagian Administrasi Pesantren untuk melakukan reset password akun Anda.',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 13,
          color: const Color(0xFF475569),
          height: 1.4,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Mengerti',
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF059669),
            ),
          ),
        ),
      ],
    );
  }
}
