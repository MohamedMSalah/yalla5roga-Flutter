import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yalla_5roga/features/groups/presentation/providers/groups_provider.dart';
import 'package:yalla_5roga/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:yalla_5roga/features/outings/presentation/providers/outing_chat_provider.dart';

/// True until the first unread/notifications fetch (mock or live) finishes.
bool shellIsLoading(BuildContext context) {
  return context.watch<NotificationsProvider>().isInitialLoading ||
      context.watch<GroupsProvider>().isInitialLoading ||
      context.watch<OutingChatProvider>().isInitialLoading;
}
