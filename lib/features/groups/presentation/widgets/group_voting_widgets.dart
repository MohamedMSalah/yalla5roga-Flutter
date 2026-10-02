import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';
import 'package:yalla_5roga/features/discover/presentation/widgets/place_category_style.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

OutingVibe _outingVibe(Outing outing) {
  if (outing.votePlaces.isNotEmpty) return outing.votePlaces.first.vibe;
  return OutingVibe.food;
}

String _dateTimeLine(Outing outing, String Function(String) digits) {
  final date = outing.date.trim();
  final time = outing.time.trim();
  if (date.isEmpty && time.isEmpty) return '';
  if (time.isEmpty) return digits(date);
  if (date.isEmpty) return digits(time);
  return digits('$date · $time');
}

double _voteCardWidth(BuildContext context) {
  final screenWidth = MediaQuery.sizeOf(context).width;
  if (Responsive.isDesktop) return Responsive.w(300);
  if (Responsive.isTablet) return Responsive.w(280);
  return (screenWidth * 0.72).clamp(Responsive.w(220), Responsive.w(280));
}

double _voteCardHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.2);
  return Responsive.h(188) * textScale;
}

/// Compact horizontal carousel card for the Groups screen.
class GroupVoteCarouselCard extends StatelessWidget {
  const GroupVoteCarouselCard({super.key, required this.outing, this.width});

  final Outing outing;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final groups = context.watch<GroupsProvider>();
    final outings = context.watch<OutingsProvider>();
    final groupName = outing.groupId == null
        ? ''
        : groups.findById(outing.groupId!)?.name ?? '';
    final vibe = _outingVibe(outing);
    final voted = outings.hasVoted(outing.id);
    final votedCount = outings.votedCountFor(outing.id);
    final dateLine = _dateTimeLine(outing, l10n.digits);
    final cardWidth = width ?? _voteCardWidth(context);

    return SizedBox(
      width: cardWidth,
      height: double.infinity,
      child: AppCard(
        borderColor: AppColors.amber100,
        padding: Responsive.padding(all: 12),
        onTap: () => Get.to(() => EventPage(event: outing)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName.isEmpty ? l10n.groupsTitle : groupName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.brand700,
                fontWeight: FontWeight.w800,
                fontSize: Responsive.fontSm,
              ),
            ),
            Responsive.spaceSm.gapH,
            Row(
              children: [
                IconCircle(
                  icon: vibe.icon,
                  size: 40,
                  iconSize: 18,
                  background: vibe.softBackground,
                  foreground: vibe.accent,
                ),
                Responsive.spaceSm.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: Responsive.fontBody,
                        ),
                      ),
                      2.gapH,
                      Text(
                        l10n.vibeLabel(vibe.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: Responsive.fontCaption,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (dateLine.isNotEmpty) ...[
              Responsive.spaceSm.gapH,
              Text(
                dateLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: palette.textMuted,
                  fontSize: Responsive.fontCaption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            Responsive.spaceSm.gapH,
            Row(
              children: [
                Flexible(
                  child: AppBadge(
                    label: voted ? l10n.youVoted : l10n.voting,
                    color: voted ? AppColors.brand50 : AppColors.amber100,
                    textColor: voted ? AppColors.brand700 : AppColors.amber700,
                  ),
                ),
                Responsive.spaceXs.gapW,
                Text(
                  l10n.votedCount(votedCount, outing.going),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontSize: Responsive.fontCaption,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomButton(
              label: voted ? l10n.viewPlan : l10n.voteNow,
              icon: voted
                  ? Icons.visibility_outlined
                  : Icons.how_to_vote_outlined,
              size: AppButtonSize.small,
              onPressed: () => Get.to(() => EventPage(event: outing)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Group-details active vote block using the shared outing/vote model.
class GroupActiveVoteTile extends StatelessWidget {
  const GroupActiveVoteTile({super.key, required this.outing});

  final Outing outing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final outings = context.watch<OutingsProvider>();
    final vibe = _outingVibe(outing);
    final voted = outings.hasVoted(outing.id);
    final dateLine = _dateTimeLine(outing, l10n.digits);
    final options = outings.optionsFor(outing.id);
    final selected = outings.voteIndexFor(outing.id);

    return AppCard(
      borderColor: AppColors.amber100,
      onTap: () => Get.to(() => EventPage(event: outing)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconCircle(
                icon: vibe.icon,
                background: vibe.softBackground,
                foreground: vibe.accent,
              ),
              Responsive.spaceSm.gapW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      outing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: Responsive.fontBody,
                      ),
                    ),
                    if (dateLine.isNotEmpty)
                      Text(
                        dateLine,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: palette.textMuted,
                          fontSize: Responsive.fontCaption,
                        ),
                      ),
                  ],
                ),
              ),
              Responsive.spaceXs.gapW,
              AppBadge(
                label: voted ? l10n.youVoted : l10n.needsYourVote,
                color: voted ? AppColors.brand50 : AppColors.amber100,
                textColor: voted ? AppColors.brand700 : AppColors.amber700,
              ),
            ],
          ),
          if (options.isNotEmpty) ...[
            Responsive.spaceSm.gapH,
            Wrap(
              spacing: Responsive.spaceSm,
              runSpacing: Responsive.spaceSm,
              children: [
                for (var i = 0; i < options.length; i++)
                  _VoteChip(
                    label: options[i].label,
                    selected: selected == i,
                    onTap: () {
                      outings.selectVoteFor(outing.id, i);
                      AppSnackBar.show(l10n.voteUpdated);
                    },
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _VoteChip extends StatelessWidget {
  const _VoteChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Material(
      color: selected ? AppColors.brand600 : palette.surfaceMuted,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: Responsive.padding(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : palette.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: Responsive.fontCaption,
            ),
          ),
        ),
      ),
    );
  }
}

/// Horizontal active-votes strip for the Groups screen.
class GroupsActiveVotesSection extends StatelessWidget {
  const GroupsActiveVotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final votes = context.watch<OutingsProvider>().activeVotes;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeVotes,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: Responsive.fontMd,
          ),
        ),
        Responsive.spaceSm.gapH,
        if (votes.isEmpty)
          AppEmptyState(
            icon: Icons.how_to_vote_outlined,
            message: l10n.noActiveVotes,
            compact: true,
          )
        else
          SizedBox(
            height: _voteCardHeight(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: votes.length,
              separatorBuilder: (_, _) => Responsive.spaceSm.gapW,
              itemBuilder: (context, index) {
                return GroupVoteCarouselCard(outing: votes[index]);
              },
            ),
          ),
      ],
    );
  }
}

/// Group-scoped active voting block for Group Details.
class GroupDetailsVotingSection extends StatelessWidget {
  const GroupDetailsVotingSection({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final votes = context.watch<OutingsProvider>().activeVotesForGroup(
      group.id,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.activeVoting,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: Responsive.fontMd,
          ),
        ),
        Responsive.spaceSm.gapH,
        if (votes.isEmpty)
          AppEmptyState(
            icon: Icons.how_to_vote_outlined,
            message: l10n.noActiveVotes,
            compact: true,
          )
        else
          for (final outing in votes) ...[
            GroupActiveVoteTile(outing: outing),
            Responsive.spaceSm.gapH,
          ],
      ],
    );
  }
}
