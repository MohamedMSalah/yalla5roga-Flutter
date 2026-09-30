import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/custom_textfield.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/group_place_suggestion.dart';
import 'package:yalla_5roga/features/outings/domain/entities/place.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_vote_widget.dart';

/// Group section: active place suggestions + create new multi-place vote with hours countdown.
class GroupPlaceSuggestSection extends StatelessWidget {
  const GroupPlaceSuggestSection({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final suggestions = outings.suggestionsForGroup(group.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.suggestPlaces,
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd),
              ),
            ),
            TextButton.icon(
              onPressed: () => _openSuggestSheet(context),
              icon: Icon(Icons.add_location_alt_outlined, size: 18.w),
              label: Text(l10n.suggest, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
            ),
          ],
        ),
        Text(
          l10n.suggestPlacesHint,
          style: TextStyle(color: context.palette.textMuted, fontSize: Responsive.fontSm),
        ),
        Responsive.spaceSm.gapH,
        if (suggestions.isEmpty)
          AppEmptyState(
            icon: Icons.add_location_alt_outlined,
            message: l10n.noPlaceSuggestions,
            compact: true,
          )
        else
          for (final suggestion in suggestions) ...[
            _SuggestionCard(group: group, suggestion: suggestion),
            8.gapH,
          ],
      ],
    );
  }

  Future<void> _openSuggestSheet(BuildContext context) async {
    final titleController = TextEditingController(text: context.l10n.defaultOutingName);
    final selected = <Place>{};
    var hours = 3;

    try {
      final created = await Get.bottomSheet<bool>(
        SafeArea(
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final l10n = context.l10n;
              final palette = context.palette;
              return Container(
                height: Responsive.height * 0.78,
                padding: Responsive.padding(all: 20),
                decoration: BoxDecoration(
                  color: palette.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.suggestPlaces, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
                    Text(l10n.suggestPlacesSheetHint, style: TextStyle(color: palette.textMuted, fontSize: 11.sp)),
                    Responsive.spaceMd.gapH,
                    CustomTextField(
                      controller: titleController,
                      label: l10n.outingName,
                      hint: l10n.defaultOutingName,
                    ),
                    Responsive.spaceMd.gapH,
                    Row(
                      children: [
                        Expanded(
                          child: Text(l10n.voteDeadlineHours, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                        ),
                        IconButton(
                          onPressed: hours <= 1
                              ? null
                              : () => setModalState(() => hours -= 1),
                          icon: const Icon(Icons.remove_circle_outline),
                          color: AppColors.brand600,
                        ),
                        Text(l10n.hoursCount(hours), style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.brand700)),
                        IconButton(
                          onPressed: hours >= 72
                              ? null
                              : () => setModalState(() => hours += 1),
                          icon: const Icon(Icons.add_circle_outline),
                          color: AppColors.brand600,
                        ),
                      ],
                    ),
                    Responsive.spaceSm.gapH,
                    Text(
                      l10n.placesSelected(selected.length),
                      style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: 10.sp),
                    ),
                    Responsive.spaceSm.gapH,
                    Expanded(
                      child: ListView(
                        children: [
                          for (final place in context.read<DiscoverProvider>().catalogPlaces()) ...[
                            AppCard(
                              onTap: () => setModalState(() {
                                if (selected.contains(place)) {
                                  selected.remove(place);
                                } else if (selected.length < OutingsProvider.maxVotePlaces) {
                                  selected.add(place);
                                } else {
                                  AppSnackBar.show(l10n.pickAtMostFivePlaces);
                                }
                              }),
                              color: selected.contains(place) ? palette.brandSoft : null,
                              borderColor: selected.contains(place) ? palette.brandSoftBorder : null,
                              child: Row(
                                children: [
                                  IconCircle(
                                    icon: Icons.location_on_outlined,
                                    background: selected.contains(place) ? AppColors.brand600 : AppColors.brand50,
                                    foreground: selected.contains(place) ? Colors.white : AppColors.brand600,
                                  ),
                                  12.gapW,
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                                        Text(place.area, style: TextStyle(color: palette.textMuted, fontSize: 10.sp)),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    selected.contains(place) ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: selected.contains(place) ? AppColors.brand600 : palette.border,
                                  ),
                                ],
                              ),
                            ),
                            8.gapH,
                          ],
                        ],
                      ),
                    ),
                    CustomButton(
                      label: l10n.publishSuggestion,
                      onPressed: () {
                        if (titleController.text.trim().isEmpty) {
                          AppSnackBar.show(l10n.nameRequired);
                          return;
                        }
                        if (selected.length < 2) {
                          AppSnackBar.show(l10n.pickAtLeastTwoPlaces);
                          return;
                        }
                        if (selected.length > OutingsProvider.maxVotePlaces) {
                          AppSnackBar.show(l10n.pickAtMostFivePlaces);
                          return;
                        }
                        Get.back(result: true);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        isScrollControlled: true,
      );

      if (created != true || !context.mounted) return;
      final auth = context.read<AuthProvider>();
      final outing = await context.read<OutingsProvider>().suggestPlaces(
            groupId: group.id,
            title: titleController.text.trim(),
            places: selected.toList(),
            deadlineHours: hours,
            createdBy: auth.user?.name ?? 'You',
            createdById: auth.user?.id,
          );
      if (!context.mounted) return;
      await context.read<NotificationsProvider>().emitLocal(
            body: context.l10n.notifOutingSuggestion(outing.title),
            outingId: outing.id,
            action: true,
          );
      if (!context.mounted) return;
      AppSnackBar.show(context.l10n.placesSuggested);
      Get.to(() => EventPage(event: outing));
    } finally {
      titleController.dispose();
    }
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.group, required this.suggestion});

  final Group group;
  final GroupPlaceSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final outings = context.watch<OutingsProvider>();
    final outing = outings.findById(suggestion.outingId);
    final endsAt = outings.voteEndsAt(suggestion.outingId);
    final voted = outings.hasVoted(suggestion.outingId);

    return AppCard(
      borderColor: AppColors.amber100,
      onTap: outing == null ? null : () => Get.to(() => EventPage(event: outing)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconCircle(
                icon: Icons.place_outlined,
                background: AppColors.amber100,
                foreground: AppColors.amber700,
              ),
              12.gapW,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(suggestion.title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
                    Text(
                      l10n.suggestedBy(suggestion.createdBy),
                      style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: l10n.placesCount(suggestion.places.length),
                color: AppColors.brand50,
                textColor: AppColors.brand600,
              ),
            ],
          ),
          10.gapH,
          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              for (final place in suggestion.places)
                AppBadge(
                  label: place.name,
                  color: context.palette.surfaceMuted,
                  textColor: context.palette.textSecondary,
                ),
            ],
          ),
          10.gapH,
          Row(
            children: [
              if (endsAt != null) Expanded(child: VoteCountdownText(endsAt: endsAt)),
              AppBadge(
                label: voted ? l10n.youVoted : l10n.needsYourVote,
                color: voted ? AppColors.emerald50 : AppColors.amber100,
                textColor: voted ? const Color(0xFF059669) : AppColors.amber700,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
