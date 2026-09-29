import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_bottom_nav.dart';
import 'package:yalla_5roga/core/widgets/app_bottom_nav_layout.dart';
import 'package:yalla_5roga/features/groups/presentation/pages/groups_page.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/home/presentation/pages/home_page.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/outings_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outing_chat_provider.dart';
import 'package:yalla_5roga/features/setting/presentation/pages/settings_page.dart';
import 'package:yalla_5roga/features/shell/presentation/providers/shell_provider.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _refreshUnread();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _refreshUnread();
    }
  }

  void _refreshUnread() {
    context.read<NotificationsProvider>().refresh();
    context.read<OutingChatProvider>().refresh();
    context.read<GroupsProvider>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shell = context.watch<ShellProvider>();

    return AppBottomNavLayout(
      currentIndex: shell.index,
      onChanged: shell.setIndex,
      pages: [
        // HomePage — tab 0
        HomePage(onSeeAllOutings: shell.openOutings),
        // GroupsPage — tab 1
        const GroupsPage(),
        // OutingsPage — tab 2
        const OutingsPage(),
        // SettingsPage — tab 3
        const SettingsPage(),
      ],
      items: [
        AppBottomNavItem(icon: Icons.home_rounded, label: l10n.navHome),
        AppBottomNavItem(icon: Icons.groups_2_rounded, label: l10n.navGroups),
        AppBottomNavItem(icon: Icons.explore_outlined, label: l10n.navOutings),
        AppBottomNavItem(icon: Icons.settings_outlined, label: l10n.navSettings),
      ],
    );
  }
}
