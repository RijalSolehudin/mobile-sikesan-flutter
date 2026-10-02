import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/dashboard_metric_model.dart';
import '../../../data/models/spp_models.dart';

/// Komponen pemilihan santri (Chips santri asuhan wali & Pencarian global untuk bendahara)
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppStudentSelector extends StatelessWidget {
  final bool isGuardian;
  final List<StudentSummaryModel> dashboardStudents;
  final int? selectedStudentId;
  final ValueChanged<StudentSummaryModel> onSelectGuardianStudent;
  final TextEditingController searchController;
  final bool isSearchingStudent;
  final List<StudentLookupModel> searchedStudents;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<StudentLookupModel> onSelectLookupStudent;

  const SppStudentSelector({
    super.key,
    required this.isGuardian,
    required this.dashboardStudents,
    required this.selectedStudentId,
    required this.onSelectGuardianStudent,
    required this.searchController,
    required this.isSearchingStudent,
    required this.searchedStudents,
    required this.onSearchChanged,
    required this.onSelectLookupStudent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Nama Santri',
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (isGuardian) ...[
          if (dashboardStudents.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Text(
                'Belum ada santri terhubung dengan akun Anda',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: dashboardStudents.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: dashboardStudents.length == 1 ? 1 : 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                mainAxisExtent: 64,
              ),
              itemBuilder: (context, index) {
                final st = dashboardStudents[index];
                final isSelected = selectedStudentId == st.id;

                return InkWell(
                  onTap: () => onSelectGuardianStudent(st),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF5F5FE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5B58EB)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.6 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF5B58EB,
                                ).withValues(alpha: 0.12),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF5B58EB)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.school_rounded,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                st.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                st.grade,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isSelected
                                      ? const Color(0xFF5B58EB)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        if (isSelected)
                          Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              color: Color(0xFF5B58EB),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          )
                        else
                          Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ] else ...[
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Cari nama atau NIS santri...',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: Color(0xFF94A3B8),
              ),
              suffixIcon: isSearchingStudent
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: Color(0xFF5B58EB),
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onSearchChanged,
          ),
          if (searchedStudents.isNotEmpty) ...[
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 160),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: searchedStudents.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final st = searchedStudents[index];
                  return ListTile(
                    dense: true,
                    title: Text(
                      st.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Text(
                      '${st.nis} • ${st.grade}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onTap: () => onSelectLookupStudent(st),
                  );
                },
              ),
            ),
          ],
        ],
      ],
    );
  }
}
