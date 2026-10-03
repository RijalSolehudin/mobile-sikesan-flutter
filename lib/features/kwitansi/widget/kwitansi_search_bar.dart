import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class KwitansiSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onCalendarTap;
  final bool hasActiveDateFilter;

  const KwitansiSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onCalendarTap,
    this.hasActiveDateFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search Input
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFF94A3B8),
                    size: 20,
                  ),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 20,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                        onPressed: () {
                          controller.clear();
                          onChanged('');
                        },
                      )
                    : null,
                hintText: 'Cari Nama Penerima',
                hintStyle: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Calendar Button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onCalendarTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: hasActiveDateFilter
                    ? AppColors.primarySurface
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasActiveDateFilter
                      ? AppColors.primary
                      : const Color(0xFFE2E8F0),
                  width: hasActiveDateFilter ? 1.5 : 1.0,
                ),
              ),
              child: Icon(
                Icons.calendar_month_outlined,
                size: 20,
                color: hasActiveDateFilter
                    ? AppColors.primary
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
