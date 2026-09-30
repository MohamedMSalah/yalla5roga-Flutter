import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

/// Full voting card for an outing: header + selectable place options.
class OutingVoteWidget extends StatelessWidget {
  const OutingVoteWidget({
    super.key,
    required this.outing,
    this.showHeader = true,
    this.compact = false,
  });

  final Outing outing;
  final bool showHeader;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (outing.status != OutingStatus.voting) return const SizedBox.shrink();

    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final options = outings.optionsFor(outing.id);
    if (options.isEmpty) return const SizedBox.shrink();

    final selected = outings.voteIndexFor(outing.id);
    final totalMembers = outing.going;
    final voted = outings.votedCountFor(outing.id).clamp(0, totalMembers);

    return AppCard(
      borderColor: AppColors.amber100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Row(
              children: [
                const IconCircle(
                  icon: Icons.how_to_vote_outlined,
                  background: AppColors.amber100,
                  foreground: AppColors.amber700,
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outing.title,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp),
                      ),
                      Text(
                        l10n.pickFavoritePlace,
                        style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                AppBadge(
                  label: l10n.votedCount(voted, totalMembers),
                  color: AppColors.brand50,
                  textColor: AppColors.brand600,
                ),
              ],
            ),
            12.gapH,
          ],
          OutingVoteOptions(
            options: options,
            selectedIndex: selected,
            compact: compact,
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
          if (outings.voteEndsAt(outing.id) != null) ...[
            12.gapH,
            VoteCountdownText(endsAt: outings.voteEndsAt(outing.id)!),
          ],
        ],
      ),
    );
  }
}

/// Selectable place rows used by [OutingVoteWidget] and [VoteCard].
class OutingVoteOptions extends StatelessWidget {
  const OutingVoteOptions({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
    this.compact = false,
  });

  final List<VoteOption> options;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;

    return Column(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) Responsive.spaceSm.gapH,
          _VoteOptionTile(
            label: options[i].label,
            votesLabel: l10n.votesPercent(options[i].votes, options[i].percent),
            percent: options[i].percent,
            selected: selectedIndex == i,
            compact: compact,
            onTap: () => onSelected(i),
            muted: palette.textMuted,
            surface: palette.surface,
            border: palette.border,
            brandSoft: palette.brandSoft,
          ),
        ],
      ],
    );
  }
}

class _VoteOptionTile extends StatelessWidget {
  const _VoteOptionTile({
    required this.label,
    required this.votesLabel,
    required this.percent,
    required this.selected,
    required this.compact,
    required this.onTap,
    required this.muted,
    required this.surface,
    required this.border,
    required this.brandSoft,
  });

  final String label;
  final String votesLabel;
  final int percent;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  final Color muted;
  final Color surface;
  final Color border;
  final Color brandSoft;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(compact ? 10.w : 12.w),
          decoration: BoxDecoration(
            color: selected ? brandSoft : surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AppColors.brand500 : border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? AppColors.brand600 : Colors.transparent,
                      border: Border.all(
                        color: selected ? AppColors.brand600 : border,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Icon(Icons.check, size: 12.w, color: Colors.white)
                        : null,
                  ),
                  Responsive.spaceSm.gapW,
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: Responsive.fontSm,
                        color: selected ? context.palette.brandStrong : null,
                      ),
                    ),
                  ),
                  Text(
                    votesLabel,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      color: selected ? AppColors.brand600 : muted,
                    ),
                  ),
                ],
              ),
              if (!compact) ...[
                Responsive.spaceSm.gapH,
                ClipRRect(
                  borderRadius: BorderRadius.circular(999.r),
                  child: LinearProgressIndicator(
                    value: (percent.clamp(0, 100)) / 100,
                    minHeight: 6.h,
                    backgroundColor: border.withValues(alpha: 0.45),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      selected ? AppColors.brand600 : AppColors.brand200,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Live countdown for vote deadlines.
class VoteCountdownText extends StatefulWidget {
  const VoteCountdownText({super.key, required this.endsAt, this.style});

  final DateTime endsAt;
  final TextStyle? style;

  @override
  State<VoteCountdownText> createState() => _VoteCountdownTextState();
}

class _VoteCountdownTextState extends State<VoteCountdownText> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(seconds: 30)),
      builder: (context, _) {
        final remaining = widget.endsAt.difference(DateTime.now());
        final l10n = context.l10n;
        final label = remaining.isNegative || remaining == Duration.zero
            ? l10n.voteEnded
            : l10n.endsInDuration(remaining.inHours, remaining.inMinutes.remainder(60));
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 14.w, color: AppColors.amber700),
            6.gapW,
            Text(
              label,
              style: widget.style ??
                  TextStyle(
                    color: AppColors.amber700,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ],
        );
      },
    );
  }
}
