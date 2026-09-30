import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/core/utils/extensions.dart';
import 'package:yalla_5roga/core/widgets/app_card.dart';
import 'package:yalla_5roga/core/widgets/app_empty_state.dart';
import 'package:yalla_5roga/core/widgets/app_icon_button.dart';
import 'package:yalla_5roga/core/widgets/app_snackbar.dart';
import 'package:yalla_5roga/core/widgets/custom_button.dart';
import 'package:yalla_5roga/core/widgets/segmented_tabs.dart';
import 'package:yalla_5roga/features/notifications/presentation/widgets/notifications_skeleton.dart';
import 'package:yalla_5roga/features/groups/presentation/pages/group_details_page.dart';
import 'package:yalla_5roga/features/notifications/domain/entities/notification_item.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/widgets/notification_card.dart';
import 'package:yalla_5roga/features/outings/presentation/pages/event_page.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outings_provider.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  var _markedOnOpen = false;
  NotificationsProvider? _notifications;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _notifications = context.read<NotificationsProvider>();
      _notifications!.addListener(_markAllWhenReady);
      _markAllWhenReady();
    });
  }

  @override
  void dispose() {
    _notifications?.removeListener(_markAllWhenReady);
    super.dispose();
  }

  void _markAllWhenReady() {
    final notifications = _notifications;
    if (!mounted || notifications == null || _markedOnOpen || !notifications.hasLoaded) return;
    _markedOnOpen = true;
    notifications.removeListener(_markAllWhenReady);
    notifications.markAllRead();
  }

  Future<void> _open(NotificationItem item) async {
    final notifications = context.read<NotificationsProvider>();
    if (item.unread) {
      final marked = await notifications.markRead(item.id);
      if (!marked || !mounted) return;
    }
    if (item.outingId != null) {
      final outing = context.read<OutingsProvider>().byId(item.outingId!);
      Get.to(() => EventPage(event: outing));
      return;
    }
    if (item.groupId != null) {
      // TODO: Get.to GroupDetailsPage from GET /groups/{item.groupId} when group CRUD exists.
      Get.to(() => GroupDetailsPage(groupId: item.groupId!));
    }
  }

  Future<void> _markAll() async {
    final l10n = context.l10n;
    final marked = await context.read<NotificationsProvider>().markAllRead();
    if (marked && mounted) {
      AppSnackBar.show(l10n.allNotificationsRead);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifications = context.watch<NotificationsProvider>();
    final unreadCount = notifications.unreadCount;
    final unread = notifications.items.where((item) => item.unread).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: Responsive.pagePadding(),
          children: [
            Row(
              children: [
                AppIconButton(icon: context.chevronBack, onTap: Get.back),
                Expanded(
                  child: Column(
                    children: [
                      Text(l10n.notifications, style: TextStyle(fontWeight: FontWeight.w800, fontSize: Responsive.fontMd)),
                      Text(l10n.unreadUpdates(unreadCount), style: TextStyle(color: context.palette.textMuted, fontSize: 10.sp)),
                    ],
                  ),
                ),
                CustomButton(
                  label: unreadCount == 0 ? l10n.allRead : l10n.markAllRead,
                  size: AppButtonSize.small,
                  expand: false,
                  variant: AppButtonVariant.light,
                  isLoading: notifications.isUpdating,
                  onPressed: unreadCount == 0 ? null : _markAll,
                ),
              ],
            ),
            Responsive.spaceMd.gapH,
            if (notifications.isInitialLoading || (notifications.isLoading && notifications.items.isEmpty))
              const NotificationsSkeleton()
            else
              SegmentedTabs(
                labels: [l10n.all, l10n.unread],
                index: notifications.filter,
                onChanged: notifications.setFilter,
                badges: {1: l10n.n(unreadCount)},
                children: [
                  _feed(notifications.items, unreadOnly: false),
                  _feed(unread, unreadOnly: true),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _feed(List<NotificationItem> items, {required bool unreadOnly}) {
    final l10n = context.l10n;
    if (items.isEmpty) {
      return AppEmptyState(
        icon: unreadOnly ? Icons.mark_email_read_outlined : Icons.notifications_none_outlined,
        message: unreadOnly ? l10n.noUnreadNotifications : l10n.noNotifications,
        subtitle: unreadOnly ? l10n.noUnreadNotificationsHint : l10n.noNotificationsHint,
        compact: true,
      );
    }
    final today = NotificationsProvider.todayFrom(items);
    final earlier = NotificationsProvider.earlierFrom(items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (today.isNotEmpty) ...[
          Text(
            l10n.today.toUpperCase(),
            style: TextStyle(
              color: context.palette.textMuted,
              fontSize: Responsive.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Responsive.spaceSm.gapH,
          ListCard(
            children: [
              for (final item in today)
                NotificationCard(
                  body: item.body,
                  time: item.time,
                  unread: item.unread,
                  image: item.image,
                  actionLabel: item.action ? l10n.voteNow : null,
                  onAction: () => _open(item),
                  onTap: () => _open(item),
                ),
            ],
          ),
        ],
        if (earlier.isNotEmpty) ...[
          Responsive.spaceLg.gapH,
          Text(
            l10n.earlier.toUpperCase(),
            style: TextStyle(
              color: context.palette.textMuted,
              fontSize: Responsive.fontCaption,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          Responsive.spaceSm.gapH,
          ListCard(
            children: [
              for (final item in earlier)
                NotificationCard(
                  body: item.body,
                  time: item.time,
                  unread: item.unread,
                  image: item.image,
                  onTap: () => _open(item),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
