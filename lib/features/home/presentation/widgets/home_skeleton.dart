import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/features/discover/presentation/pages/discover_page.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/home_header.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/quick_actions.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key, this.onSeeAllOutings});

  final VoidCallback? onSeeAllOutings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: Responsive.pagePadding(),
        children: [
          const HomeHeader(),
          Responsive.spaceMd.gapH,
          AppShimmer(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: ShimmerBone(
                    width: double.infinity,
                    height: 176.h,
                    radius: 0,
                  ),
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
              ],
            ),
          ),
          Responsive.spaceLg.gapH,
          SectionHeader(title: l10n.quickActions, subtitle: l10n.makeItHappen),
          12.gapH,
          const QuickActions(),
          Responsive.spaceLg.gapH,
          SectionHeader(
            title: l10n.discover,
            subtitle: l10n.exploreNearby,
            actionLabel: l10n.seeAll,
            onAction: () => Get.to(() => const DiscoverPage()),
          ),
          12.gapH,
          const AppShimmer(child: ShimmerDiscoverStrip(count: 3)),
          Responsive.spaceMd.gapH,
          Text(
            l10n.nearbyPlaces.toUpperCase(),
            style: TextStyle(
              color: context.palette.textMuted,
              fontSize: Responsive.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Responsive.spaceSm.gapH,
          const AppShimmer(child: ShimmerPlaceList(count: 3)),
          Responsive.spaceLg.gapH,
          SectionHeader(
            title: l10n.happeningNow,
            actionLabel: l10n.seeAll,
            onAction: onSeeAllOutings,
          ),
          12.gapH,
          const AppShimmer(child: ShimmerOutingList(count: 3)),
        ],
      ),
    );
  }
}
