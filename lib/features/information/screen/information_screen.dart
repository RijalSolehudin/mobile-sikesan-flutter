import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/announcement_repository.dart';
import '../bloc/announcement_bloc.dart';
import '../widget/information_header.dart';
import '../widget/information_metric_cards.dart';
import '../widget/information_filter_bar.dart';
import '../widget/information_empty_state.dart';
import '../widget/announcement_card_tile.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../core/widgets/app_snackbar.dart';
import 'announcement_detail_screen.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repo = context.read<AnnouncementRepository>();
        return AnnouncementBloc(repository: repo)
          ..add(const AnnouncementFetchRequested());
      },
      child: const _InformationScreenBody(),
    );
  }
}

class _InformationScreenBody extends StatelessWidget {
  const _InformationScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<AnnouncementBloc, AnnouncementState>(
        listener: (context, state) {
          if (state.status == AnnouncementStatus.error &&
              state.errorMessage != null) {
            AppSnackBar.showError(context, state.errorMessage!);
          }
        },
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<AnnouncementBloc>().add(
                const AnnouncementRefreshRequested(),
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  InformationHeader(
                    onAddAnnouncement: () {
                      AppSnackBar.showInfo(
                        context,
                        'Form pengumuman sedang dalam pengembangan.',
                      );
                    },
                  ),
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Metric Cards (data dinamis dari BLoC)
                            InformationMetricCards(
                              totalInfo: state.totalCount,
                              unreadCount: state.draftCount,
                              readCount: state.publishedCount,
                              importantCount: state.importantCount,
                            ),
                            const SizedBox(height: 16),

                            // Filter Bar
                            InformationFilterBar(
                              categories: AnnouncementBloc.categories,
                              selectedCategoryIndex:
                                  state.selectedCategoryIndex,
                              onCategorySelected: (index) {
                                context.read<AnnouncementBloc>().add(
                                  AnnouncementCategoryChanged(index),
                                );
                              },
                              statuses: AnnouncementBloc.statuses,
                              selectedStatusIndex: state.selectedStatusIndex,
                              onStatusSelected: (index) {
                                context.read<AnnouncementBloc>().add(
                                  AnnouncementStatusChanged(index),
                                );
                              },
                              onSearchChanged: (query) {
                                context.read<AnnouncementBloc>().add(
                                  AnnouncementSearchChanged(query),
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Content List
                            _buildContent(context, state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnnouncementState state) {
    if (state.status == AnnouncementStatus.loading) {
      return Column(
        children: List.generate(
          3,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ShimmerBox(
              width: double.infinity,
              height: 140,
              borderRadius: 16,
            ),
          ),
        ),
      );
    }

    if (state.filteredAnnouncements.isEmpty) {
      return const InformationEmptyState(
        message: 'Tidak ada pengumuman ditemukan.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: state.filteredAnnouncements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final announcement = state.filteredAnnouncements[index];
        return AnnouncementCardTile(
          announcement: announcement,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    AnnouncementDetailScreen(announcement: announcement),
              ),
            );
          },
        );
      },
    );
  }
}
