import 'package:billova/utils/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerHelper extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerHelper({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors().creamcolor,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors().creamcolor,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class ProductGridShimmer extends StatelessWidget {
  const ProductGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width < 600 ? 3 : 6,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: 9, // Dummy count
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const ShimmerHelper(width: 60, height: 60, radius: 12),
              const SizedBox(height: 8),
              const ShimmerHelper(width: 80, height: 12, radius: 4),
              const SizedBox(height: 5),
              const ShimmerHelper(width: 50, height: 12, radius: 4),
            ],
          ),
        );
      },
    );
  }
}

class ProductListShimmer extends StatelessWidget {
  const ProductListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const ShimmerHelper(width: 50, height: 50, radius: 8),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerHelper(width: 150, height: 14, radius: 4),
                    const SizedBox(height: 10),
                    const ShimmerHelper(width: 80, height: 12, radius: 4),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategoryShimmer extends StatelessWidget {
  const CategoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: 6,
        itemBuilder: (_, __) {
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ShimmerHelper(width: 80, height: 40, radius: 20),
          );
        },
      ),
    );
  }
}
