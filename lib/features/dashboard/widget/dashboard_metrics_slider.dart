import 'package:flutter/material.dart';
import '../../../core/widgets/shimmer_box.dart';

class DashboardMetricsSlider extends StatelessWidget {
  final List<Widget> cards;
  final bool isLoading;
  final bool isWide;
  final PageController pageController;
  final int carouselIndex;
  final ValueChanged<int> onPageChanged;

  const DashboardMetricsSlider({
    super.key,
    required this.cards,
    required this.isLoading,
    required this.isWide,
    required this.pageController,
    required this.carouselIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const ShimmerBox(
        width: double.infinity,
        height: 140,
        borderRadius: 16,
      );
    }

    if (isWide) {
      return Row(
        children: cards
            .map(
              (card) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: card,
                ),
              ),
            )
            .toList(),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView(
            controller: pageController,
            onPageChanged: onPageChanged,
            children: cards,
          ),
        ),
        const SizedBox(height: 12),
        // Carousel Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(cards.length, (index) {
            final bool isSelected = carouselIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 4,
              width: isSelected ? 20 : 6,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }
}
