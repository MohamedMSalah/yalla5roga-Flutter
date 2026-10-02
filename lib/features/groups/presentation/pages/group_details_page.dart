import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/utils/member_display_name.dart';
import 'package:yalla_5roga/core/utils/app_permissions.dart';
import 'package:yalla_5roga/core/widgets/app_badge.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_network_image.dart';
import 'package:yalla_5roga/core/widgets/app_page_bar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/features/groups/presentation/pages/group_info_page.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_details_skeleton.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_place_suggest_section.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_voting_widgets.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/create_outing_page.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/widgets/outing_list_tile.dart';

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
    final groupOutings = context.watch<OutingsProvider>().forGroup(group.id);

    return Scaffold(
      appBar: AppPageBar(
        title: group.name,
        trailingIcon: Icons.settings_outlined,
        onTrailingTap: () => Get.to(() => GroupInfoPage(groupId: groupId)),
      ),
      body: ListView(
        padding: Responsive.pagePadding(),
        children: [
          AppNetworkImage(
            url: group.image,
            width: double.infinity,
            height: 180.h,
            radius: 22.r,
            placeholderIcon: Icons.groups_outlined,
          ),
          Responsive.spaceMd.gapH,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: Responsive.fontLg,
                      ),
                    ),
                    Text(
                      l10n.membersOutings(
                        group.people.length,
                        groupOutings.length,
                      ),
                      style: TextStyle(
                        color: palette.textMuted,
                        fontSize: Responsive.fontSm,
                      ),
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
          CustomButton(
            label: l10n.createOuting,
            icon: Icons.add,
            onPressed: () => Get.to(() => CreateOutingPage(group: group)),
          ),
          Responsive.spaceLg.gapH,
          GroupDetailsVotingSection(group: group),
          Responsive.spaceLg.gapH,
          GroupPlaceSuggestSection(group: group),
          Responsive.spaceLg.gapH,
          Text(
            l10n.groupOutings,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: Responsive.fontMd,
            ),
          ),
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
                subtitle: l10n.digits(
                  '${outing.date} · ${outing.time} · ${outing.meta}',
                ),
                image: outing.image,
                onTap: () => Get.to(() => EventPage(event: outing)),
              ),
              8.gapH,
            ],
        ],
      ),
    );
  }
}
