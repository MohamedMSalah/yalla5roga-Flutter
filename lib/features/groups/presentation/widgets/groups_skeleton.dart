import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';

class GroupsSkeleton extends StatelessWidget {
  const GroupsSkeleton({super.key});

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
                const Expanded(child: ShimmerSectionHeader(eyebrow: true, wideTitle: true)),
                const ShimmerIconButton(),
              ],
            ),
            Responsive.spaceSm.gapH,
            Row(
              children: [
                const ShimmerIconButton(),
                Responsive.spaceSm.gapW,
                const ShimmerIconButton(),
              ],
            ),
            Responsive.spaceMd.gapH,
            const ShimmerChipRow(),
            Responsive.spaceMd.gapH,
            const ListCard(
              children: [
                ShimmerFeaturedGroup(),
                ShimmerGroupCard(),
                ShimmerGroupCard(),
                _CreateGroupBone(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateGroupBone extends StatelessWidget {
  const _CreateGroupBone();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.spaceMd),
      decoration: BoxDecoration(
        color: context.palette.brandSoft,
        borderRadius: BorderRadius.circular(Responsive.radiusLg),
        border: Border.all(color: context.palette.brandSoftBorder),
      ),
      child: Row(
        children: [
          ShimmerBone(width: 44.w, height: 44.w, radius: 14),
          12.gapW,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 130.w, height: 13.h),
                Responsive.spaceXs.gapH,
                ShimmerLine(width: 160.w, height: 9.h),
              ],
            ),
          ),
          ShimmerBone(width: 16.w, height: 16.w, radius: 4),
        ],
      ),
    );
  }
}
