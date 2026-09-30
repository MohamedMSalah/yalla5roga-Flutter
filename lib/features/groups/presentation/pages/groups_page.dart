import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/theme/app_colors.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/filter_chip_row.dart';
import 'package:yalla_5roga/core/widgets/notification_button.dart';
import 'package:yalla_5roga/core/widgets/section_header.dart';
import 'package:yalla_5roga/features/groups/presentation/pages/create_group_page.dart';
import 'package:yalla_5roga/features/groups/presentation/pages/group_details_page.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/create_group_card.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/featured_group_card.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/group_card.dart';
import 'package:yalla_5roga/features/groups/presentation/widgets/groups_skeleton.dart';
import 'package:yalla_5roga/features/shell/presentation/widgets/shell_loading.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch(GroupsProvider groups) {
    groups.openSearch();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch(GroupsProvider groups) {
    _searchController.clear();
    _searchFocus.unfocus();
    groups.closeSearch();
  }

  @override
  Widget build(BuildContext context) {
    if (shellIsLoading(context)) return const GroupsSkeleton();

    final l10n = context.l10n;
    final palette = context.palette;
    final groups = context.watch<GroupsProvider>();
    final items = groups.visible;

    return SafeArea(
      child: ListView(
        padding: Responsive.pagePadding(),
        children: [
          // SectionHeader + NotificationButton — page title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SectionHeader(
                  eyebrow: l10n.yourCircles,
                  title: l10n.groupsTitle,
                  subtitle: l10n.activeGroupsFriends(
                    groups.groups.length,
                    groups.groups.fold<int>(0, (sum, group) => sum + group.members),
                  ),
                ),
              ),
              const NotificationButton(),
            ],
          ),
          Responsive.spaceSm.gapH,
          // AppIconButton — search (expands to TextField) and create group
          Row(
            children: [
              if (groups.searching)
                Expanded(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      onChanged: groups.setQuery,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.searchGroups,
                        filled: true,
                        fillColor: palette.inputFill,
                        prefixIcon: Icon(Icons.search, color: palette.textMuted, size: 20.w),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.close, size: 18.w, color: palette.textMuted),
                          onPressed: () => _closeSearch(groups),
                        ),
                        contentPadding: Responsive.padding(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                )
              else
                AppIconButton(icon: Icons.search, onTap: () => _openSearch(groups)),
              Responsive.spaceSm.gapW,
              AppIconButton(
                icon: Icons.add,
                background: AppColors.brand600,
                foreground: Colors.white,
                onTap: () => Get.to(() => const CreateGroupPage()),
              ),
            ],
          ),
          Responsive.spaceMd.gapH,
          // FilterChipRow — all / most active / recently added
          FilterChipRow(
            labels: [l10n.allGroups, l10n.mostActive, l10n.recentlyAdded],
            index: groups.filter,
            onChanged: groups.setFilter,
          ),
          Responsive.spaceMd.gapH,
          // FeaturedGroupCard / GroupCard / CreateGroupCard — group list
          if (items.isEmpty)
            AppEmptyState(
              icon: groups.query.trim().isEmpty ? Icons.groups_outlined : Icons.search_off_outlined,
              message: groups.query.trim().isEmpty ? l10n.noGroups : l10n.noGroupsFound,
              subtitle: groups.query.trim().isEmpty ? l10n.noGroupsHint : l10n.noGroupsFoundHint,
              compact: true,
            )
          else
            ListCard(
              children: [
                for (final group in items)
                  group.featured
                      ? FeaturedGroupCard(
                          group: group,
                          onTap: () => Get.to(() => GroupDetailsPage(groupId: group.id)),
                        )
                      : GroupCard(
                          group: group,
                          onTap: () => Get.to(() => GroupDetailsPage(groupId: group.id)),
                        ),
                if (groups.query.trim().isEmpty) CreateGroupCard(onTap: () => Get.to(() => const CreateGroupPage())),
              ],
            ),
        ],
      ),
    );
  }
}
