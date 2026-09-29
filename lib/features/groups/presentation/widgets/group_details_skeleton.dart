import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';

class GroupDetailsSkeleton extends StatelessWidget {
  const GroupDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: Responsive.pagePadding(),
        children: [
          ShimmerBone(width: double.infinity, height: 180.h, radius: 22),
          Responsive.spaceMd.gapH,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerLine(width: 160.w, height: 18.h),
                    Responsive.spaceXs.gapH,
                    ShimmerLine(width: 120.w, height: 11.h),
                  ],
                ),
              ),
              ShimmerBone(width: 56.w, height: 22.h, radius: 999),
            ],
          ),
          Responsive.spaceMd.gapH,
          ShimmerBone(width: double.infinity, height: 52.h, radius: 14),
          Responsive.spaceSm.gapH,
          ShimmerBone(width: double.infinity, height: 52.h, radius: 14),
          Responsive.spaceLg.gapH,
          ShimmerLine(width: 110.w, height: 14.h),
          Responsive.spaceSm.gapH,
          const ShimmerOutingTile(),
          8.gapH,
          const ShimmerOutingTile(),
          Responsive.spaceLg.gapH,
          ShimmerLine(width: 80.w, height: 14.h),
          Responsive.spaceSm.gapH,
          for (var i = 0; i < 3; i++) ...[
            AppCard(
              radius: 16,
              child: Row(
                children: [
                  ShimmerBone(width: 44.w, height: 44.w, radius: 12),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLine(width: 100.w, height: 12.h),
                        Responsive.spaceXs.gapH,
                        ShimmerLine(width: 64.w, height: 9.h),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            8.gapH,
          ],
        ],
      ),
    );
  }
}
