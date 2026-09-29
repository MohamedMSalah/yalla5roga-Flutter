import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final avatar = Responsive.avatarMd;

    return SafeArea(
      child: AppShimmer(
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: Responsive.pagePadding(),
          children: [
            Row(
              children: [
                ShimmerCircle(size: avatar),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLine(width: 88.w, height: 10.h),
                      Responsive.spaceXs.gapH,
                      ShimmerLine(width: 120.w, height: 14.h),
                    ],
                  ),
                ),
                const ShimmerIconButton(),
              ],
            ),
            Responsive.spaceMd.gapH,
            ClipRRect(
              borderRadius: BorderRadius.circular(24.r),
              child: ShimmerBone(width: double.infinity, height: 176.h, radius: 0),
            ),
            Responsive.spaceSm.gapH,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerBone(width: 20.w, height: 6.h, radius: 999),
                6.gapW,
                ShimmerBone(width: 6.w, height: 6.h, radius: 999),
                6.gapW,
                ShimmerBone(width: 6.w, height: 6.h, radius: 999),
              ],
            ),
            Responsive.spaceLg.gapH,
            const ShimmerSectionHeader(),
            12.gapH,
            Row(
              children: [
                for (var i = 0; i < 4; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(6.w, 12.h, 6.w, 12.h),
                        decoration: BoxDecoration(
                          color: context.palette.surface,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(color: context.palette.border),
                        ),
                        child: Column(
                          children: [
                            ShimmerBone(width: 36.w, height: 36.w, radius: 12),
                            Responsive.spaceSm.gapH,
                            ShimmerLine(width: 48.w, height: 8.h),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            8.gapH,
            ShimmerBone(width: double.infinity, height: 52.h, radius: 16),
            Responsive.spaceLg.gapH,
            const ShimmerDiscoverStrip(showPlaces: true, count: 3),
            Responsive.spaceLg.gapH,
            const ShimmerSectionHeader(action: true),
            12.gapH,
            for (var i = 0; i < 3; i++) ...[
              const ShimmerOutingTile(),
              8.gapH,
            ],
          ],
        ),
      ),
    );
  }
}
