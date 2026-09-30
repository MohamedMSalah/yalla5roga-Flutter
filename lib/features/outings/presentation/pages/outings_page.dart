import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/notification_button.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/core/widgets/segmented_tabs.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/discover_section.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/create_outing_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_items.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outings_skeleton.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_vote_widget.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/vote_card.dart';
import 'package:yalla_5roga/features/shell/presentation/widgets/shell_loading.dart';

class OutingsPage extends StatefulWidget {
  const OutingsPage({super.key});

  @override
  State<OutingsPage> createState() => _OutingsPageState();
}

class _OutingsPageState extends State<OutingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<OutingsProvider>().refreshLifecycle();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (shellIsLoading(context)) return const OutingsSkeleton();

    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final needsVote = outings.needsYourVote;

    return SafeArea(
      child: ListView(
        padding: Responsive.pagePadding(),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeader(eyebrow: l10n.makeAMemory, title: l10n.outingsTitle),
              ),
              const NotificationButton(),
            ],
          ),
          Responsive.spaceSm.gapH,
          CustomButton(
            label: l10n.plan,
            icon: Icons.add,
            size: AppButtonSize.small,
            onPressed: () => Get.to(() => const CreateOutingPage()),
          ),
          Responsive.spaceMd.gapH,
          SegmentedTabs(
            labels: [l10n.upcoming, l10n.voting, l10n.past],
            index: outings.filter,
            onChanged: outings.setFilter,
            badges: {outings.filter: l10n.n(outings.filtered.length)},
          ),
          Responsive.spaceLg.gapH,
          const DiscoverSection(limit: 4),
          Responsive.spaceLg.gapH,
          Text(
            l10n.thisWeekend.toUpperCase(),
            style: TextStyle(
              color: context.palette.textMuted,
              fontSize: Responsive.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Responsive.spaceSm.gapH,
          const OutingItems(filtered: true),
          if (needsVote.isNotEmpty) ...[
            Responsive.spaceLg.gapH,
            Row(
              children: [
                Text(
                  l10n.needsYourVote.toUpperCase(),
                  style: TextStyle(
                    color: context.palette.textMuted,
                    fontSize: Responsive.fontCaption,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                  ),
                ),
                const Spacer(),
                if (outings.voteEndsAt(needsVote.first.id) != null)
                  VoteCountdownText(endsAt: outings.voteEndsAt(needsVote.first.id)!),
              ],
            ),
            Responsive.spaceSm.gapH,
            for (final outing in needsVote) ...[
              VoteCard(outing: outing),
              Responsive.spaceSm.gapH,
            ],
          ],
        ],
      ),
    );
  }
}
