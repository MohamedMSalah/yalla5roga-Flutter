import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_role.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/member_display_name.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/image_source_sheet.dart';
import 'package:yalla_5roga/core/widgets/phone_text_field.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_details_skeleton.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_place_suggest_section.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/create_outing_page.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_list_tile.dart';
import 'package:yalla_5roga/core/utils/app_permissions.dart';

class GroupDetailsPage extends StatefulWidget {
  const GroupDetailsPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  String get groupId => widget.groupId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      context.read<GroupsProvider>().markRead(groupId);
      await AppPermissions.promptContactsAccess(context.l10n);
      if (!mounted) return;
      await MemberDisplayName.ensureLoaded();
      if (mounted) setState(() {});
    });
  }

  Future<void> _changeImage(BuildContext context, GroupsProvider groups) async {
    final url = await ImageSourceSheet.pick(title: context.l10n.changeGroupImage);
    if (url == null || !context.mounted) return;
    groups.updateImage(groupId, url);
    AppSnackBar.show(context.l10n.groupImageUpdated);
  }

  Future<void> _addMember(BuildContext context, GroupsProvider groups) async {
    final phoneController = TextEditingController();
    try {
      final added = await Get.bottomSheet<String>(
      SafeArea(
        child: Builder(
          builder: (context) {
            final l10n = context.l10n;
            final palette = context.palette;
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
                  Text(l10n.addByPhone, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
                  Responsive.spaceMd.gapH,
                  PhoneTextField(
                    controller: phoneController,
                    validate: false,
                  ),
                  Responsive.spaceMd.gapH,
                  CustomButton(
                    label: l10n.addPhone,
                    onPressed: () {
                      final error = Validators.phone(phoneController.text, l10n);
                      if (error != null) {
                        AppSnackBar.show(error);
                        return;
                      }
                      Get.back(result: Validators.normalizePhone(phoneController.text));
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

      if (added == null || !context.mounted) return;
      final l10n = context.l10n;
      final error = await groups.addMember(groupId, added, l10n);
      if (!context.mounted) return;
      if (error != null) {
        AppSnackBar.show(error);
        return;
      }
      final display = MemberDisplayName.resolvePhone(added);
      context.read<NotificationsProvider>().emitLocal(
            body: l10n.notifMemberAdded(display, groups.byId(groupId).name),
            groupId: groupId,
          );
      AppSnackBar.show(l10n.memberAdded(display));
    } finally {
      phoneController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final groups = context.watch<GroupsProvider>();
    if (groups.isInitialLoading) {
      return Scaffold(
        appBar: AppPageBar(title: l10n.groupsTitle),
        body: const GroupDetailsSkeleton(),
      );
    }
    final group = groups.byId(groupId);
    final canManage = group.myRole == GroupRole.owner || group.myRole == GroupRole.admin;
    final groupOutings = context.watch<OutingsProvider>().forGroup(group.id);

    return Scaffold(
      // AppPageBar — group name
      appBar: AppPageBar(title: group.name),
      body: ListView(
        padding: Responsive.pagePadding(),
        children: [
          // AppNetworkImage — group cover (tap to change)
          GestureDetector(
            onTap: canManage ? () => _changeImage(context, groups) : null,
            child: Stack(
              children: [
                AppNetworkImage(url: group.image, width: double.infinity, height: 180.h, radius: 22.r),
                if (canManage)
                  Positioned(
                    right: 12.w,
                    bottom: 12.h,
                    child: CircleAvatar(
                      backgroundColor: AppColors.brand600,
                      child: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 18.w),
                    ),
                  ),
              ],
            ),
          ),
          Responsive.spaceMd.gapH,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontLg)),
                    Text(
                      l10n.membersOutings(group.people.length, groupOutings.length),
                      style: TextStyle(color: palette.textMuted, fontSize: Responsive.fontSm),
                    ),
                  ],
                ),
              ),
              AppBadge(
                label: groups.roleLabel(group.myRole, l10n),
                color: AppColors.brand50,
                textColor: AppColors.brand700,
              ),
            ],
          ),
          Responsive.spaceMd.gapH,
          // CustomButton — create outing for this group
          CustomButton(
            label: l10n.createOuting,
            icon: Icons.add,
            onPressed: () => Get.to(() => CreateOutingPage(group: group)),
          ),
          if (canManage) ...[
            Responsive.spaceSm.gapH,
            CustomButton(
              label: l10n.addPeople,
              icon: Icons.person_add_alt_1_outlined,
              variant: AppButtonVariant.outlined,
              onPressed: () => _addMember(context, groups),
            ),
          ],
          Responsive.spaceLg.gapH,
          GroupPlaceSuggestSection(group: group),
          Responsive.spaceLg.gapH,
          Text(l10n.groupOutings, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
          Responsive.spaceSm.gapH,
          if (groupOutings.isEmpty)
            AppEmptyState(
              icon: Icons.event_busy_outlined,
              message: l10n.noGroupOutings,
              compact: true,
            )
          else
            for (final outing in groupOutings) ...[
              OutingListTile(
                title: outing.title,
                subtitle: l10n.digits('${outing.date} · ${outing.time} · ${outing.meta}'),
                image: outing.image,
                onTap: () => Get.to(() => EventPage(event: outing)),
              ),
              8.gapH,
            ],
          Responsive.spaceLg.gapH,
          Text(l10n.members, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
          Responsive.spaceSm.gapH,
          if (group.people.isEmpty)
            AppEmptyState(
              icon: Icons.person_off_outlined,
              message: l10n.noGoingYet,
              subtitle: l10n.noGoingYetHint,
              compact: true,
            )
          else
            for (final person in group.people) ...[
              AppCard(
                radius: 16,
                child: Row(
                  children: [
                    AppNetworkImage(url: person.avatar, width: 44.w, height: 44.w, radius: 12.r),
                    12.gapW,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            MemberDisplayName.resolve(person),
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontBody),
                          ),
                          Text(groups.roleLabel(person.role, l10n), style: TextStyle(color: palette.textMuted, fontSize: 10.sp)),
                        ],
                      ),
                    ),
                    if (canManage && person.role != GroupRole.owner)
                      IconButton(
                        onPressed: () {
                          groups.removeMember(groupId, person);
                          AppSnackBar.show(l10n.memberRemoved(MemberDisplayName.resolve(person)));
                        },
                        icon: Icon(Icons.remove_circle_outline, color: AppColors.rose500, size: 20.w),
                      ),
                  ],
                ),
              ),
              8.gapH,
            ],
        ],
      ),
    );
  }
}
