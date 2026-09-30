import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/discover_section.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/featured_outing_card.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/home_header.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/home_skeleton.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/quick_actions.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_items.dart';
import 'package:yalla_5roga/features/shell/presentation/widgets/shell_loading.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onSeeAllOutings});

  final VoidCallback? onSeeAllOutings;

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<OutingsProvider>().load(),
      context.read<DiscoverProvider>().load(),
      context.read<GroupsProvider>().refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (shellIsLoading(context)) return const HomeSkeleton();

    final l10n = context.l10n;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.brand600,
        onRefresh: () => _refreshAll(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.pagePadding(),
          children: [
            // HomeHeader — avatar, greeting, NotificationButton
            const HomeHeader(),
            Responsive.spaceMd.gapH,
            // FeaturedOutingCard — next-up outing banner
            const FeaturedOutingCard(),
            Responsive.spaceLg.gapH,
            // SectionHeader — Quick actions title
            SectionHeader(
              title: l10n.quickActions,
              subtitle: l10n.makeItHappen,
            ),
            12.gapH,
            // QuickActions — new outing, special event, group, discover, invite
            const QuickActions(),
            Responsive.spaceLg.gapH,
            // DiscoverSection — suggested outings + Nearby places (max 3)
            const DiscoverSection(showPlaces: true, limit: 3),
            Responsive.spaceLg.gapH,
            // SectionHeader — Happening now title
            SectionHeader(
              title: l10n.happeningNow,
              actionLabel: l10n.seeAll,
              onAction: onSeeAllOutings,
            ),
            12.gapH,
            // OutingItems — happening-now cards (max 3)
            const OutingItems(limit: 3),
          ],
        ),
      ),
    );
  }
}
