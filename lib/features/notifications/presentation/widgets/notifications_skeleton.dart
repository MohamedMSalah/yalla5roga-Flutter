import 'package:flutter/material.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_shimmer.dart';

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ShimmerTabs(count: 2),
          Responsive.spaceLg.gapH,
          ShimmerLine(width: 56.w, height: 9.h),
          Responsive.spaceSm.gapH,
          const ListCard(
            children: [
              ShimmerNotificationCard(unread: true),
              ShimmerNotificationCard(unread: true),
              ShimmerNotificationCard(),
            ],
          ),
          Responsive.spaceLg.gapH,
          ShimmerLine(width: 64.w, height: 9.h),
          Responsive.spaceSm.gapH,
          const ListCard(
            children: [
              ShimmerNotificationCard(),
              ShimmerNotificationCard(),
            ],
          ),
        ],
      ),
    );
  }
}
