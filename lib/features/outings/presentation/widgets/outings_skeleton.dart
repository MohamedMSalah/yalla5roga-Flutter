import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';

class OutingsSkeleton extends StatelessWidget {
  const OutingsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AppShimmer(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: Responsive.pagePadding(),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Expanded(child: ShimmerSectionHeader(eyebrow: true)),
                const ShimmerIconButton(),
              ],
            ),
            Responsive.spaceSm.gapH,
            ShimmerBone(width: double.infinity, height: 40.h, radius: 12),
            Responsive.spaceMd.gapH,
            const ShimmerTabs(),
            Responsive.spaceLg.gapH,
            const ShimmerDiscoverStrip(count: 4),
            Responsive.spaceLg.gapH,
            ShimmerLine(width: 110.w, height: 9.h),
            Responsive.spaceSm.gapH,
            for (var i = 0; i < 3; i++) ...[
              const ShimmerOutingTile(),
              8.gapH,
            ],
            Responsive.spaceLg.gapH,
            Row(
              children: [
                ShimmerLine(width: 120.w, height: 9.h),
                const Spacer(),
                ShimmerLine(width: 56.w, height: 9.h),
              ],
            ),
            Responsive.spaceSm.gapH,
            const ShimmerVoteCard(),
          ],
        ),
      ),
    );
  }
}
