import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Screen fallback yang ditampilkan secara otomatis saat terjadi unhandled error
/// pada level rendering widget (ErrorWidget.builder).
class AppCrashFallbackScreen extends StatefulWidget {
  final FlutterErrorDetails errorDetails;

  const AppCrashFallbackScreen({super.key, required this.errorDetails});

  @override
  State<AppCrashFallbackScreen> createState() => _AppCrashFallbackScreenState();
}

class _AppCrashFallbackScreenState extends State<AppCrashFallbackScreen> {
  bool _showDebugDetails = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        color: AppColors.background,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon Ilustrasi
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: AppColors.expenseSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.expense.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      size: 48,
                      color: AppColors.expense,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Judul
                  Text(
                    'Terjadi Kendala Teknis',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Deskripsi Sopan
                  Text(
                    'Mohon maaf, sistem mendeteksi kendala pada tampilan antarmuka. Anda dapat mencoba memuat ulang aplikasi atau kembali ke menu sebelumnya.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Coba Lagi / Muat Ulang
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Coba pop atau reload navigasi jika memungkinkan
                        final nav = Navigator.maybeOf(context);
                        if (nav != null && nav.canPop()) {
                          nav.pop();
                        } else {
                          // Jika root atau modal, arahkan ke route awal jika ada router
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(
                        'Muat Ulang Halaman',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Debug Details Toggle (Hanya di mode Debug / Profile)
                  if (kDebugMode) ...[
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _showDebugDetails = !_showDebugDetails;
                        });
                      },
                      icon: Icon(
                        _showDebugDetails
                            ? Icons.expand_less_rounded
                            : Icons.bug_report_outlined,
                        size: 18,
                        color: AppColors.textMuted,
                      ),
                      label: Text(
                        _showDebugDetails
                            ? 'Sembunyikan Detail Log'
                            : 'Lihat Detail Error (Debug)',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    if (_showDebugDetails) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.darkSlate,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(
                            widget.errorDetails.exceptionAsString(),
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
