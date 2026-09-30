import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_vote_widget.dart';

class VoteCard extends StatelessWidget {
  const VoteCard({super.key, required this.outing});

  final Outing outing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final options = outings.optionsFor(outing.id);
    final selected = outings.voteIndexFor(outing.id);
    final voted = outings.votedCountFor(outing.id).clamp(0, outing.going);
    final endsAt = outings.voteEndsAt(outing.id);

    return AppCard(
      borderColor: AppColors.amber100,
      onTap: () => Get.to(() => EventPage(event: outing)),
      child: Column(
        children: [
          Row(
            children: [
              const IconCircle(
                icon: Icons.restaurant,
                background: AppColors.amber100,
                foreground: AppColors.amber700,
              ),
              12.gapW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(outing.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    Text(l10n.pickFavoritePlace, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
                  ],
                ),
              ),
              AppBadge(
                label: l10n.votedCount(voted, outing.going),
                color: AppColors.brand50,
                textColor: AppColors.brand600,
              ),
            ],
          ),
          12.gapH,
          OutingVoteOptions(
            options: options,
            selectedIndex: selected,
            compact: true,
            onSelected: (index) {
              outings.selectVoteFor(outing.id, index);
              context.read<NotificationsProvider>().emitLocal(
                    body: l10n.notifPlaceVoted(outing.title),
                    eventId: outing.id,
                    action: true,
                  );
              AppSnackBar.show(l10n.voteUpdated);
            },
          ),
          if (endsAt != null) ...[
            10.gapH,
            VoteCountdownText(endsAt: endsAt),
          ],
        ],
      ),
    );
  }
}
