import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/member_display_name.dart';
import 'package:yalla_5roga/core/utils/validators.dart';
import 'package:yalla_5roga/core/widgets/app_alert.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/image_source_sheet.dart';
import 'package:yalla_5roga/core/widgets/phone_text_field.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_member.dart';
import 'package:yalla_5roga/features/groups/domain/entities/group_role.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_details_skeleton.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/shell/presentation/providers/shell_provider.dart';

class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({super.key, required this.groupId});

  final String groupId;

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  String get groupId => widget.groupId;
  var _leaving = false;

  Future<void> _changeImage(BuildContext context, GroupsProvider groups) async {
    final url = await ImageSourceSheet.pick(
      title: context.l10n.changeGroupImage,
    );
    if (url == null || !context.mounted) return;
    await groups.updateImage(groupId, url);
    if (!context.mounted) return;
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
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24.r),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.addByPhone,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: Responsive.fontMd,
                      ),
                    ),
                    Responsive.spaceMd.gapH,
                    PhoneTextField(
                      controller: phoneController,
                      validate: false,
                    ),
                    Responsive.spaceMd.gapH,
                    CustomButton(
                      label: l10n.addPhone,
                      onPressed: () {
                        final error = Validators.phone(
                          phoneController.text,
                          l10n,
                        );
                        if (error != null) {
                          AppSnackBar.show(error);
                          return;
                        }
                        Get.back(
                          result: Validators.normalizePhone(
                            phoneController.text,
                          ),
                        );
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
      final display = l10n.digits(MemberDisplayName.resolvePhone(added));
      AppSnackBar.show(l10n.memberAdded(display));
    } finally {
      phoneController.dispose();
    }
  }

  Future<void> _confirmRemove(
    BuildContext context,
    GroupsProvider groups,
    GroupMember person,
  ) async {
    final l10n = context.l10n;
    final name = l10n.digits(MemberDisplayName.resolve(person));
    final confirmed = await AppAlert.confirm(
      title: l10n.removeMemberTitle,
      message: l10n.removeMemberMessage(name),
      confirmText: l10n.removeMember,
      cancelText: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    await groups.removeMember(groupId, person);
    if (!context.mounted) return;
    AppSnackBar.show(l10n.memberRemoved(name));
  }

  Future<void> _confirmLeave(
    BuildContext context,
    GroupsProvider groups,
  ) async {
    final l10n = context.l10n;
    final confirmed = await AppAlert.confirm(
      title: l10n.leaveGroupTitle,
      message: l10n.leaveGroupMessage,
      confirmText: l10n.leaveGroup,
      cancelText: l10n.cancel,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    setState(() => _leaving = true);
    final ok = await groups.leaveGroup(groupId);
    if (!mounted) return;
    setState(() => _leaving = false);

    if (!ok) {
      if (groups.errorMessage != null) {
        AppSnackBar.show(groups.errorMessage!);
      }
      return;
    }

    AppSnackBar.show(l10n.leftGroup);
    if (!context.mounted) return;
    context.read<ShellProvider>().setIndex(1);
    Get.until((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = context.palette;
    final groups = context.watch<GroupsProvider>();
    if (groups.isInitialLoading) {
      return Scaffold(
        appBar: AppPageBar(title: l10n.groupInfo),
        body: const GroupDetailsSkeleton(),
      );
    }

    final group = groups.findById(groupId);
    if (group == null) {
      return Scaffold(
        appBar: AppPageBar(title: l10n.groupInfo),
        body: AppEmptyState(
          icon: Icons.groups_outlined,
          message: l10n.noGroups,
          compact: true,
        ),
      );
    }

    final canManage = groups.canManage(group);
    final outingCount = context
        .watch<OutingsProvider>()
        .forGroup(group.id)
        .length;
    final headerHeight = (MediaQuery.sizeOf(context).width * 0.42).clamp(
      150.0,
      220.0,
    );

    return Scaffold(
      appBar: AppPageBar(title: l10n.groupInfo),
      body: ListView(
        padding: Responsive.pagePadding(),
        children: [
          GestureDetector(
            onTap: canManage ? () => _changeImage(context, groups) : null,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                AppNetworkImage(
                  url: group.image,
                  width: double.infinity,
                  height: headerHeight,
                  radius: 22.r,
                  placeholderIcon: Icons.groups_outlined,
                ),
                if (canManage)
                  Positioned(
                    right: 12.w,
                    bottom: 12.h,
                    child: CircleAvatar(
                      backgroundColor: AppColors.brand600,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 18.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Responsive.spaceMd.gapH,
          Text(
            group.name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: Responsive.fontLg,
            ),
          ),
          6.gapH,
          Text(
            l10n.membersOutings(group.people.length, outingCount),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: palette.textMuted,
              fontSize: Responsive.fontSm,
            ),
          ),
          Responsive.spaceSm.gapH,
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.groupBio,
                  style: TextStyle(
                    color: palette.textMuted,
                    fontWeight: FontWeight.w700,
                    fontSize: Responsive.fontCaption,
                  ),
                ),
                6.gapH,
                Text(
                  group.bio.trim().isEmpty ? l10n.noGroupBio : group.bio,
                  style: TextStyle(
                    color: group.bio.trim().isEmpty
                        ? palette.textMuted
                        : palette.textPrimary,
                    fontSize: Responsive.fontBody,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Responsive.spaceLg.gapH,
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.members,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: Responsive.fontMd,
                  ),
                ),
              ),
              if (canManage)
                TextButton.icon(
                  onPressed: () => _addMember(context, groups),
                  icon: Icon(Icons.person_add_alt_1_outlined, size: 18.w),
                  label: Text(l10n.addPeople),
                ),
            ],
          ),
          Responsive.spaceSm.gapH,
          if (group.people.isEmpty)
            AppEmptyState(
              icon: Icons.person_off_outlined,
              message: l10n.nothingHere,
              compact: true,
            )
          else
            for (final person in group.people) ...[
              AppCard(
                radius: 16,
                child: Row(
                  children: [
                    AppNetworkImage.avatar(
                      url: person.avatar,
                      width: 44.w,
                      height: 44.w,
                      radius: 12.r,
                    ),
                    12.gapW,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.digits(MemberDisplayName.resolve(person)),
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: Responsive.fontBody,
                            ),
                          ),
                          if (person.phone != null && person.phone!.isNotEmpty)
                            Text(
                              l10n.digits(person.phone!),
                              style: TextStyle(
                                color: palette.textMuted,
                                fontSize: 10.sp,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (person.role == GroupRole.owner)
                      AppBadge(
                        label: l10n.owner.toUpperCase(),
                        color: AppColors.brand50,
                        textColor: AppColors.brand700,
                      )
                    else if (canManage)
                      IconButton(
                        tooltip: l10n.removeMember,
                        onPressed: () =>
                            _confirmRemove(context, groups, person),
                        icon: Icon(
                          Icons.remove_circle_outline,
                          color: AppColors.rose500,
                          size: 20.w,
                        ),
                      ),
                  ],
                ),
              ),
              8.gapH,
            ],
          Responsive.spaceLg.gapH,
          Text(
            l10n.groupActions,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: Responsive.fontMd,
            ),
          ),
          Responsive.spaceSm.gapH,
          CustomButton(
            label: l10n.leaveGroup,
            icon: Icons.logout_rounded,
            variant: AppButtonVariant.danger,
            isLoading: _leaving,
            onPressed: _leaving ? null : () => _confirmLeave(context, groups),
          ),
          Responsive.spaceLg.gapH,
        ],
      ),
    );
  }
}
