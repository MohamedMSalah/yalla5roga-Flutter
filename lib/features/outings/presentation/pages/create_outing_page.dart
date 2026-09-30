import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/localization/l10n.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/custom_textfield.dart';
import 'package:yalla_5roga/core/widgets/icon_circle.dart';
import 'package:yalla_5roga/core/widgets/image_source_sheet.dart';
import 'package:yalla_5roga/features/auth/presentation/providers/auth_provider.dart';
import 'package:yalla_5roga/features/discover/domain/entities/suggested_place.dart';
import 'package:yalla_5roga/features/discover/presentation/providers/discover_provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/domain/entities/outing_enums.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/pick_location_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/create_outing_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/saved_outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/vibe_picker.dart';

class CreateOutingPage extends StatelessWidget {
  const CreateOutingPage({
    super.key,
    this.group,
    this.suggestedPlace,
    this.saved,
    this.draft,
    this.specialEvent = false,
  });

  final Group? group;
  final SuggestedPlace? suggestedPlace;
  final SavedOuting? saved;
  final OutingDraft? draft;
  final bool specialEvent;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final groups = context.read<GroupsProvider>();
        final outings = context.read<OutingsProvider>();
        final discover = context.read<DiscoverProvider>();
        final form = CreateOutingProvider(
          groups: groups.groups,
          contacts: groups.contacts,
          catalogPlaces: discover.catalogPlaces().isNotEmpty
              ? discover.catalogPlaces()
              : outings.places,
          specialEventImage: outings.specialEventImage,
          group: group,
          suggestedPlace: suggestedPlace,
          saved: saved,
          draft: draft,
          specialEvent: specialEvent,
        );
        form.applySuggestionTitle(context.l10n);
        return form;
      },
      child: const _CreateOutingView(),
    );
  }
}

class _CreateOutingView extends StatelessWidget {
  const _CreateOutingView();

  Future<void> _pickCustomLocation(BuildContext context, CreateOutingProvider form) async {
    final picked = await Get.to<PickedPlace>(
      () => PickLocationPage(
        placeName: form.customPlaceController.text.trim(),
        initialLatitude: form.customLatitude,
        initialLongitude: form.customLongitude,
      ),
    );
    if (picked == null || !context.mounted) return;
    form.applyPickedPlace(picked);
  }

  Future<void> _pickDate(BuildContext context, CreateOutingProvider form) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: form.clampDate(form.date),
      firstDate: form.minDate,
      lastDate: form.maxDate,
    );
    if (picked == null) return;
    form.setDate(picked);
  }

  Future<void> _pickTime(BuildContext context, CreateOutingProvider form) async {
    final picked = await showTimePicker(context: context, initialTime: form.time);
    if (picked == null) return;
    form.setTime(picked);
  }

  Future<void> _pickGroup(BuildContext context, CreateOutingProvider form) async {
    if (form.groupLocked) return;
    final selected = await Get.bottomSheet<Group>(
      SafeArea(
        child: Builder(
          builder: (context) {
            final palette = context.palette;
            final l10n = context.l10n;
            return Container(
              padding: Responsive.padding(all: 20),
              decoration: BoxDecoration(
                color: palette.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.chooseGroup, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
                  Responsive.spaceMd.gapH,
                  for (final group in form.groups)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: AppNetworkImage(url: group.image, width: 40.w, height: 40.w, radius: 12.r),
                      title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(l10n.membersWillBeInvited(group.people.length)),
                      trailing: form.group?.id == group.id
                          ? Icon(Icons.check_circle, color: AppColors.brand600, size: 22.w)
                          : null,
                      onTap: () => Get.back(result: group),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (selected == null) return;
    form.setGroup(selected);
  }

  void _next(BuildContext context, CreateOutingProvider form) {
    final error = form.next(context.l10n);
    if (error != null) AppSnackBar.show(error);
  }

  void _create(BuildContext context, CreateOutingProvider form) {
    final userId = context.read<AuthProvider>().user?.id;
    final outing = form.buildOuting(createdById: userId);
    context.read<OutingsProvider>().add(outing);
    if (form.draft != null) {
      context.read<SavedOutingsProvider>().removeDraft(form.draft!.id);
    }
    context.read<NotificationsProvider>().emitLocal(
          body: context.l10n.notifOutingCreated(outing.title),
          eventId: outing.id,
        );
    AppSnackBar.show(context.l10n.outingCreated);
    Get.off(() => EventPage(event: outing));
  }

  Future<void> _saveDraft(BuildContext context, CreateOutingProvider form) async {
    final l10n = context.l10n;
    final error = form.draftError(l10n);
    if (error != null) {
      AppSnackBar.show(error);
      return;
    }
    await context.read<SavedOutingsProvider>().saveDraft(form.toDraft());
    if (!context.mounted) return;
    AppSnackBar.show(l10n.draftSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final form = context.watch<CreateOutingProvider>()..syncLocale(l10n);
    final titles = [l10n.theBasics, l10n.chooseLocation, l10n.reviewOuting];
    final headlines = [l10n.whatAreWeDoing, l10n.pickAPlace, l10n.reviewOuting];
    final bodies = [l10n.addEssentials, l10n.chooseLocationNext, l10n.almostThere];
    final actions = [l10n.continueToLocation, l10n.continueToReview, l10n.createAndGo];

    return Scaffold(
      // AppPageBar — create outing / special event
      appBar: AppPageBar(
        title: form.specialEvent ? l10n.createSpecialEvent : l10n.createOuting,
        subtitle: form.specialEvent ? l10n.specialEventSubtitle : l10n.funStartsHere,
        backIcon: form.step == 0 ? Icons.close : Icons.chevron_left,
        onBack: () => form.step == 0 ? Get.back() : form.back(),
        trailing: form.step == 2
            ? TextButton(
                onPressed: () => _saveDraft(context, form),
                child: Text(
                  l10n.saveDraft,
                  style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: Responsive.fontSm),
                ),
              )
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: Responsive.padding(horizontal: 20, top: 16, bottom: 20),
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < 3; i++) ...[
                        if (i > 0) 6.gapW,
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: i <= form.step
                                  ? (i == form.step ? AppColors.brand600 : AppColors.brand200)
                                  : context.palette.border,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                          ),
                        ),
                      ],
                      Responsive.spaceSm.gapW,
                      Text(l10n.stepOf(form.step + 1, 3), style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: 10.sp)),
                    ],
                  ),
                  Responsive.spaceLg.gapH,
                  Text(titles[form.step].toUpperCase(), style: TextStyle(color: AppColors.brand600, fontSize: 10.sp, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                  Text(headlines[form.step], style: TextStyle(fontSize: Responsive.fontLg, fontWeight: FontWeight.w800)),
                  Responsive.spaceXs.gapH,
                  Text(bodies[form.step], style: TextStyle(color: context.palette.textMuted, fontSize: 12.sp)),
                  Responsive.spaceLg.gapH,
                  if (form.step == 0) _basics(context, l10n, form),
                  if (form.step == 1) _location(context, l10n, form),
                  if (form.step == 2) _review(context, l10n, form),
                ],
              ),
            ),
            Padding(
              padding: Responsive.padding(horizontal: 20, top: 8, bottom: 16),
              child: CustomButton(
                label: form.step == 2 && form.specialEvent ? l10n.createSpecialEvent : actions[form.step],
                icon: Icons.arrow_forward,
                onPressed: form.step == 2 ? () => _create(context, form) : () => _next(context, form),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _basics(BuildContext context, L10n l10n, CreateOutingProvider form) {
    final preview = form.image ?? (form.specialEvent ? form.resolvedImage : null);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () async {
            final path = await ImageSourceSheet.pick(title: context.l10n.uploadPhoto);
            if (path == null) return;
            form.setImage(path);
          },
          child: preview == null
              ? Container(
                  height: 140.h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.palette.surfaceMuted,
                    borderRadius: BorderRadius.circular(22.r),
                    border: Border.all(color: context.palette.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined, color: AppColors.brand600, size: 28.w),
                      8.gapH,
                      Text(l10n.uploadPhoto, style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800)),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    AppNetworkImage(url: preview, width: double.infinity, height: 140.h, radius: 22.r),
                    if (form.specialEvent && form.image == null)
                      Positioned(
                        right: 12.w,
                        bottom: 12.h,
                        child: Container(
                          padding: Responsive.padding(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Text(
                            l10n.uploadPhoto,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10.sp),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        Responsive.spaceMd.gapH,
        CustomTextField(
          controller: form.nameController,
          label: form.specialEvent ? l10n.eventName : l10n.outingName,
          prefixIcon: Icons.auto_awesome,
        ),
        Responsive.spaceMd.gapH,
        if (form.specialEvent) ...[
          Text(l10n.specialEvent, style: TextStyle(fontSize: Responsive.fontSm, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
          Responsive.spaceXs.gapH,
          Text(l10n.specialEventHint, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
          Responsive.spaceSm.gapH,
          VibePicker(
            options: [
              VibeOption('🎂', l10n.birthday),
              VibeOption('💍', l10n.wedding),
            ],
            index: form.occasion == OutingOccasion.wedding ? 1 : 0,
            onChanged: (index) => form.setOccasion(index == 1 ? OutingOccasion.wedding : OutingOccasion.birthday),
          ),
          Responsive.spaceMd.gapH,
          Row(
            children: [
              Expanded(
                child: Text(l10n.invitePeople, style: TextStyle(fontSize: Responsive.fontSm, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
              ),
              TextButton(
                onPressed: form.toggleSelectAll,
                child: Text(
                  form.allGuestsSelected ? l10n.clearSelection : l10n.selectAll,
                  style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: Responsive.fontSm),
                ),
              ),
            ],
          ),
          Text(l10n.invitePeopleHint, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
          Responsive.spaceSm.gapH,
          for (final person in form.contacts) ...[
            AppCard(
              onTap: () => form.toggleGuest(person.id),
              color: form.guestIds.contains(person.id) ? context.palette.brandSoft : null,
              borderColor: form.guestIds.contains(person.id) ? context.palette.brandSoftBorder : null,
              child: Row(
                children: [
                  AppNetworkImage(url: person.avatar, width: 40.w, height: 40.w, radius: 12.r),
                  12.gapW,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        Text(
                          context.read<GroupsProvider>().groupsForMember(person.id),
                          style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: form.guestIds.contains(person.id),
                    activeColor: AppColors.brand600,
                    onChanged: (_) => form.toggleGuest(person.id),
                  ),
                ],
              ),
            ),
            8.gapH,
          ],
        ] else ...[
          Text(l10n.pickAVibe, style: TextStyle(fontSize: Responsive.fontSm, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
          Responsive.spaceSm.gapH,
          VibePicker(
            options: [
              VibeOption('🍽️', l10n.food),
              VibeOption('🎳', l10n.activity),
              VibeOption('🌿', l10n.outdoor),
              VibeOption('🎬', l10n.movie),
            ],
            index: form.vibe,
            onChanged: form.setVibe,
          ),
          Responsive.spaceMd.gapH,
          Text(l10n.inviteAGroup, style: TextStyle(fontSize: Responsive.fontSm, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
          Responsive.spaceSm.gapH,
          AppCard(
            onTap: form.groupLocked ? null : () => _pickGroup(context, form),
            color: form.group == null ? context.palette.brandSoft : null,
            borderColor: form.group == null ? context.palette.brandSoftBorder : null,
            child: Row(
              children: [
                IconCircle(
                  icon: Icons.groups_2_outlined,
                  background: form.group == null ? AppColors.brand50 : AppColors.brand600,
                  foreground: form.group == null ? AppColors.brand600 : Colors.white,
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(form.group?.name ?? l10n.chooseGroup, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(
                        form.group == null ? l10n.inviteAGroup : l10n.membersWillBeInvited(form.group!.people.length),
                        style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                if (!form.groupLocked) Icon(Icons.unfold_more, color: context.palette.textMuted),
              ],
            ),
          ),
        ],
        Responsive.spaceMd.gapH,
        Row(
          children: [
            Expanded(
              child: AppCard(
                onTap: () => _pickDate(context, form),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.date, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
                    Responsive.spaceSm.gapH,
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: AppColors.brand600),
                        Responsive.spaceSm.gapW,
                        Expanded(
                          child: Text(
                            form.shortDate,
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            10.gapW,
            Expanded(
              child: AppCard(
                onTap: () => _pickTime(context, form),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.time, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: context.palette.textSecondary)),
                    Responsive.spaceSm.gapH,
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 16, color: AppColors.brand600),
                        Responsive.spaceSm.gapW,
                        Expanded(
                          child: Text(form.formattedTime, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (!form.specialEvent) ...[
          12.gapH,
          AppCard(
            color: context.palette.brandSoft,
            borderColor: context.palette.brandSoftBorder,
            onTap: form.toggleLetVote,
            child: Row(
              children: [
                Checkbox(
                  value: form.letVote,
                  activeColor: AppColors.brand600,
                  onChanged: (value) => form.setLetVote(value ?? false),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.addPlacesForVoting, style: TextStyle(color: context.palette.brandStrong, fontWeight: FontWeight.w800, fontSize: 12.sp)),
                      Text(l10n.addPlacesForVotingHint, style: TextStyle(color: AppColors.brand500, fontSize: 10.sp)),
                    ],
                  ),
                ),
                const Icon(Icons.how_to_vote_outlined, color: AppColors.brand600),
              ],
            ),
          ),
          if (form.letVote) ...[
            12.gapH,
            AppCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.voteDeadlineHours, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp)),
                        Text(l10n.voteDeadlineHint, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: form.voteDeadlineHours <= 1 ? null : () => form.setVoteDeadlineHours(form.voteDeadlineHours - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppColors.brand600,
                  ),
                  Text(
                    l10n.hoursCount(form.voteDeadlineHours),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp, color: AppColors.brand700),
                  ),
                  IconButton(
                    onPressed: form.voteDeadlineHours >= 72 ? null : () => form.setVoteDeadlineHours(form.voteDeadlineHours + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppColors.brand600,
                  ),
                ],
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _location(BuildContext context, L10n l10n, CreateOutingProvider form) {
    final multi = form.multiPlaceMode;
    return Column(
      children: [
        if (multi) ...[
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.pickMultiplePlaces,
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontSm),
            ),
          ),
          Responsive.spaceXs.gapH,
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              l10n.placesSelectedMax(form.selectedPlaces.length, OutingsProvider.maxVotePlaces),
              style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: 10.sp),
            ),
          ),
          Responsive.spaceMd.gapH,
        ] else ...[
          AppCard(
            onTap: () => _pickCustomLocation(context, form),
            color: form.customPlacePinned ? context.palette.brandSoft : null,
            borderColor: form.customPlacePinned ? context.palette.brandSoftBorder : null,
            child: Row(
              children: [
                IconCircle(
                  icon: form.customPlacePinned ? Icons.check_circle : Icons.add_location_alt_outlined,
                  background: form.customPlacePinned ? AppColors.brand600 : AppColors.brand50,
                  foreground: form.customPlacePinned ? Colors.white : AppColors.brand600,
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        form.isCustomPlace ? form.customPlaceController.text.trim() : l10n.pickOnMap,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        form.customPlacePinned ? l10n.changeMapLocation : l10n.locationHint,
                        style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.map_outlined, color: AppColors.brand600, size: 20.w),
              ],
            ),
          ),
          Responsive.spaceMd.gapH,
        ],
        for (final place in form.catalogPlaces) ...[
          AppCard(
            onTap: () => form.togglePlace(place),
            color: (multi ? form.isPlaceSelected(place) : form.place == place) ? context.palette.brandSoft : null,
            borderColor: (multi ? form.isPlaceSelected(place) : form.place == place) ? context.palette.brandSoftBorder : null,
            child: Row(
              children: [
                IconCircle(
                  icon: Icons.location_on_outlined,
                  background: (multi ? form.isPlaceSelected(place) : form.place == place) ? AppColors.brand600 : AppColors.brand50,
                  foreground: (multi ? form.isPlaceSelected(place) : form.place == place) ? Colors.white : AppColors.brand600,
                ),
                12.gapW,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                      Text(place.area, style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
                    ],
                  ),
                ),
                if (multi
                    ? form.isPlaceSelected(place)
                    : form.place == place)
                  Icon(multi ? Icons.check_box : Icons.check_circle, color: AppColors.brand600, size: 20.w)
                else if (multi)
                  Icon(Icons.check_box_outline_blank, color: context.palette.border, size: 20.w),
              ],
            ),
          ),
          8.gapH,
        ],
      ],
    );
  }

  Widget _review(BuildContext context, L10n l10n, CreateOutingProvider form) {
    return Column(
      children: [
        AppNetworkImage(url: form.resolvedImage, width: double.infinity, height: 160.h, radius: 22.r),
        Responsive.spaceMd.gapH,
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(form.nameController.text.trim(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
              if (form.occasion != OutingOccasion.none) ...[
                Responsive.spaceXs.gapH,
                Text(
                  form.occasion == OutingOccasion.birthday ? l10n.birthday : l10n.wedding,
                  style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: 12.sp),
                ),
              ],
              Responsive.spaceSm.gapH,
              Text(form.locationLabel, style: TextStyle(color: context.palette.textMuted)),
              if (form.multiPlaceMode) ...[
                Responsive.spaceXs.gapH,
                Text(
                  l10n.voteClosesInHours(form.voteDeadlineHours),
                  style: TextStyle(color: AppColors.amber700, fontWeight: FontWeight.w800, fontSize: 10.sp),
                ),
              ],
              if (form.selectedLocation?.hasCoordinates ?? false) ...[
                Responsive.spaceXs.gapH,
                Text(l10n.locationPinned, style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800, fontSize: 10.sp)),
              ],
              Responsive.spaceSm.gapH,
              Text('${form.formattedDate} · ${form.formattedTime}', style: const TextStyle(fontWeight: FontWeight.w700)),
              Responsive.spaceSm.gapH,
              Text(
                form.specialEvent
                    ? l10n.guestsInvited(form.guestIds.length)
                    : form.group == null
                        ? l10n.chooseGroup
                        : l10n.membersWillBeInvited(form.group!.people.length),
                style: TextStyle(color: AppColors.brand600, fontWeight: FontWeight.w800),
              ),
              if (form.specialEvent)
                Text(form.guestNames.join(', '), style: const TextStyle(fontWeight: FontWeight.w800))
              else if (form.group != null)
                Text(form.group!.name, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}
