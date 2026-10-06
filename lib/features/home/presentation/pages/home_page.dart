import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/lists/discover_section.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/lists/happening_now_list.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/cards/featured_outing_card.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/home_header.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/home_skeleton.dart';
import 'package:yalla_5roga/features/home/presentation/widgets/quick_actions.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/shell/presentation/widgets/shell_loading.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onSeeAllOutings});

  final VoidCallback? onSeeAllOutings;

  Future<void> _refreshAll(BuildContext context) async {
    await Future.wait([
      context.read<OutingsProvider>().load(forceRefresh: true),
      context.read<DiscoverProvider>().load(forceRefresh: true),
      context.read<GroupsProvider>().refresh(forceRefresh: true),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    if (shellIsLoading(context)) {
      return HomeSkeleton(onSeeAllOutings: onSeeAllOutings);
    }

    final l10n = context.l10n;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.brand600,
        onRefresh: () => _refreshAll(context),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.pagePadding(),
          children: [
            const HomeHeader(),
            Responsive.spaceMd.gapH,
            const FeaturedOutingCard(),
            Responsive.spaceLg.gapH,
            SectionHeader(
              title: l10n.quickActions,
              subtitle: l10n.makeItHappen,
            ),
            12.gapH,
            const QuickActions(),
            Responsive.spaceLg.gapH,
            const DiscoverSection(showPlaces: true, limit: 3),
            Responsive.spaceLg.gapH,
            HappeningNowList(onSeeAll: onSeeAllOutings),
          ],
        ),
      ),
    );
  }
}
