import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/avatar_stack.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/create_outing_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

class FeaturedGroupCard extends StatelessWidget {
  const FeaturedGroupCard({super.key, required this.group, this.onTap});

  final Group group;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final groupOutings = outings.forGroup(group.id);
    final needsVote = outings.needsYourVote.where(
      (item) => item.groupId == group.id,
    );
    final nextOuting = needsVote.isNotEmpty
        ? needsVote.first
        : groupOutings.isEmpty
        ? null
        : groupOutings.first;

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.radiusLg),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(Responsive.spaceMd),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.brand700, Color(0xFF8B5CF6)],
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppBadge(
                          label: l10n.activeNow,
                          color: Colors.white.withValues(alpha: 0.16),
                          textColor: Colors.white,
                        ),
                        Responsive.spaceSm.gapH,
                        Text(
                          group.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: Responsive.fontMd,
                          ),
                        ),
                        Text(
                          l10n.membersOutings(
                            group.people.length,
                            groupOutings.length,
                          ),
                          style: TextStyle(
                            color: AppColors.brand100,
                            fontSize: Responsive.fontCaption,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Responsive.spaceSm.gapW,
                  AvatarStack(
                    urls: group.avatars.take(2).toList(),
                    extra: (group.memberCount - 2).clamp(0, 99),
                  ),
                ],
              ),
            ),
            Container(
              color: context.palette.surface,
              padding: Responsive.padding(all: 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.currentDecision,
                              style: TextStyle(
                                color: context.palette.textMuted,
                                fontSize: Responsive.fontCaption,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              nextOuting?.title ??
                                  group.decision ??
                                  l10n.whereShouldWeGo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: Responsive.fontBody,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (nextOuting != null) ...[
                        Responsive.spaceSm.gapW,
                        AppBadge(
                          label: l10n.votedCount(
                            outings.votedCountFor(nextOuting.id),
                            group.memberCount,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Responsive.spaceSm.gapH,
                  CustomButton(
                    label: l10n.voteNow,
                    icon: Icons.how_to_vote_outlined,
                    size: AppButtonSize.small,
                    onPressed: () => nextOuting == null
                        ? Get.to(() => CreateOutingPage(group: group))
                        : Get.to(() => EventPage(event: nextOuting)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
